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
    yum install -y docker git
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
