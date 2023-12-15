data "aws_partition" "current" {}

data "aws_ami" "amazon-linux-2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-*-x86_64"]
  }
}

resource "aws_instance" "bastion_host" {
  count = var.create_bastion ? 1 : 0

  ami                     = data.aws_ami.amazon-linux-2023.id
  instance_type           = "m5.xlarge"
  subnet_id               = module.vpc.private_subnets[0]
  vpc_security_group_ids  = [aws_security_group.bastion_host_security_group[0].id]
  iam_instance_profile    = aws_iam_instance_profile.bastion-host-instance-profile[0].name
  disable_api_termination = true

  root_block_device {
    encrypted   = true
    volume_size = 120
    volume_type = "gp3"
  }

  user_data = <<EOF
		#! /bin/bash
    sudo yum install -y git libicu
    curl -L https://github.com/defenseunicorns/uds-cli/releases/download/v0.4.1/uds-cli_v0.4.1_Linux_amd64 -o uds
    chmod +x uds
    sudo mv uds /usr/local/bin/
    curl -L https://github.com/defenseunicorns/zarf/releases/download/v0.31.4/zarf_v0.31.4_Linux_amd64 -o zarf
    chmod +x zarf
    sudo mv zarf /usr/local/bin
    # Install Actions Runner
    mkdir actions-runner && cd actions-runner
    curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz    
    echo "29fc8cf2dab4c195bb147384e7e2c94cfd4d4022c793b346a6175435265aa278  actions-runner-linux-x64-2.311.0.tar.gz" | shasum -a 256 -c
    tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz
    # Manual config of runner for now
EOF

  #checkov:skip=CKV_AWS_135:t3.nano have ebs_optimization enabled by default
  # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-optimized.html
  monitoring = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }
  tags = {
    Name = "bastion-host"
  }
}

resource "aws_security_group" "bastion_host_security_group" {
  count = var.create_bastion ? 1 : 0

  #checkov:skip=CKV2_AWS_5:SG is used in VPC Endpoint and will be used by EC2 but not in this module
  name        = "bastion-host-security-group"
  description = "Security group for bastion host"
  vpc_id      = module.vpc.vpc_id
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description      = "Allow traffic on all ports and ip ranges"
  }
}

resource "aws_iam_role" "bastion-host-instance-role" {
  count = var.create_bastion ? 1 : 0

  managed_policy_arns = [
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })

  permissions_boundary = var.permissions_boundary
}

resource "aws_iam_instance_profile" "bastion-host-instance-profile" {
  count = var.create_bastion ? 1 : 0

  role = aws_iam_role.bastion-host-instance-role[0].name
  tags = {
    Name = "bastion-host-instance-profile"
  }
}
