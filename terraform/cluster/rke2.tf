data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_s3_bucket" "oidc_bucket" {
  bucket = "${var.environment}-oidc"
}

locals {
  # NOTE: This needs to match the cluster name in ../irsa/iam.tf
  # and ../vpc/vpc.tf
  cluster_name = "uds-${var.environment}"

  pre_userdata = templatefile(var.pre_userdata_base_file, {
    environment                 = var.environment
    bucket_regional_domain_name = data.aws_s3_bucket.oidc_bucket.bucket_regional_domain_name
  })

  pre_userdata_lfai_additional = file(var.lfai_pre_userdata_additional_file)

  post_userdata = file(var.post_userdata_base_file)

  resource_prefix = "uds-core-${var.environment}-"
}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["uds-${var.environment}"]
  }
}

data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*public*"]
  }
}

data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}

module "rke2" {
  source = "github.com/rancherfederal/rke2-aws-tf?ref=v2.4.0"

  cluster_name         = local.cluster_name
  unique_suffix        = false
  vpc_id               = data.aws_vpc.vpc.id
  subnets              = var.public_access ? data.aws_subnets.public_subnets.ids : data.aws_subnets.private_subnets.ids
  iam_instance_profile = "${var.environment}-rke2-server"

  #
  # Server pool config
  #
  instance_type            = var.server_instance_type
  ami                      = var.rke2_ami
  iam_permissions_boundary = var.permissions_boundary
  block_device_mappings = {
    size      = var.server_block_device_size
    encrypted = true
    type      = "gp3"
  }
  servers                     = var.num_rke2_servers
  extra_block_device_mappings = var.server_extra_block_device_mappings

  #
  # Controlplane Config
  #
  controlplane_internal = var.public_access ? false : true

  #
  # RKE2 Config
  #
  download                  = false
  pre_userdata              = local.pre_userdata
  post_userdata             = local.post_userdata
  enable_ccm                = true
  ccm_external              = true
  wait_for_capacity_timeout = "30m"

  ssh_authorized_keys         = var.enable_ssh ? [tls_private_key.ssh[0].public_key_openssh] : []
  associate_public_ip_address = var.public_access ? true : false
}

module "rke2_agents" {
  source = "github.com/rancherfederal/rke2-aws-tf//modules/agent-nodepool?ref=v2.4.0"

  name          = "agent"
  vpc_id        = data.aws_vpc.vpc.id
  subnets       = var.public_access ? data.aws_subnets.public_subnets.ids : data.aws_subnets.private_subnets.ids
  ami           = var.rke2_ami
  instance_type = var.agent_instance_type

  #
  # Nodepool Config
  #
  iam_permissions_boundary = var.permissions_boundary
  block_device_mappings = {
    size      = var.agent_block_device_size
    encrypted = true
    type      = "gp3"
  }
  asg = {
    min : var.agent_asg_min,
    max : var.agent_asg_max,
    desired : var.agent_asg_desired,
    termination_policies : ["Default"]
  }
  extra_block_device_mappings = var.agent_extra_block_device_mappings

  #
  # RKE2 Config
  #
  cluster_data              = module.rke2.cluster_data
  enable_ccm                = true
  ccm_external              = true
  download                  = false
  pre_userdata              = local.pre_userdata
  post_userdata             = local.post_userdata
  wait_for_capacity_timeout = "30m"

  ssh_authorized_keys = var.enable_ssh ? [tls_private_key.ssh[0].public_key_openssh] : []
}

module "lfai_rke2_agents" {
  count = var.enable_lfai_agents ? 1 : 0

  source = "github.com/rancherfederal/rke2-aws-tf//modules/agent-nodepool?ref=v2.4.0"

  name          = "lfai_agent"
  vpc_id        = data.aws_vpc.vpc.id
  subnets       = var.public_access ? data.aws_subnets.public_subnets.ids : data.aws_subnets.private_subnets.ids
  ami           = var.lfai_rke2_ami
  instance_type = var.lfai_agent_instance_type

  #
  # Nodepool Config
  #
  iam_permissions_boundary = var.permissions_boundary
  block_device_mappings = {
    size      = var.lfai_agent_block_device_size
    encrypted = true
    type      = "gp3"
  }
  asg = {
    min : var.lfai_agent_asg_min,
    max : var.lfai_agent_asg_max,
    desired : var.lfai_agent_asg_desired,
    termination_policies : ["Default"]
  }
  extra_block_device_mappings = var.lfai_agent_extra_block_device_mappings

  #
  # RKE2 Config
  #
  cluster_data              = module.rke2.cluster_data
  enable_ccm                = true
  ccm_external              = true
  download                  = false
  pre_userdata              = "${local.pre_userdata}${local.pre_userdata_lfai_additional}"
  post_userdata             = local.post_userdata
  wait_for_capacity_timeout = "30m"

  ssh_authorized_keys = var.enable_ssh ? [tls_private_key.ssh[0].public_key_openssh] : []
}

#
# SSH Config for Testing
#
resource "tls_private_key" "ssh" {
  count = var.enable_ssh ? 1 : 0

  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "ssh_pem" {
  count = var.enable_ssh ? 1 : 0

  filename        = "${local.cluster_name}.pem"
  content         = tls_private_key.ssh[0].private_key_pem
  file_permission = "0600"
}

resource "aws_security_group_rule" "quickstart_ssh" {
  count = var.enable_ssh ? 1 : 0

  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = module.rke2.cluster_data.cluster_sg
  type              = "ingress"
  cidr_blocks       = var.public_access ? ["0.0.0.0/0"] : [data.aws_vpc.vpc.cidr_block]
}

#
# AWS Load Balancer Controller
#
resource "aws_iam_policy" "aws_lb_controller_policy" {
  name = "${var.environment}-aws-lb-controller-policy"
  policy = templatefile("templates/aws_lb_controller_policy.json.tpl", {
    vpc_arn       = data.aws_vpc.vpc.arn
    arn_partition = data.aws_partition.current.partition
  })
}

resource "aws_iam_role" "aws_lb_controller_role" {
  name = "${var.environment}-aws-lb-controller-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
          "Federated" : "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${data.aws_s3_bucket.oidc_bucket.bucket_regional_domain_name}"
        }
        "Condition" : {
          "StringEquals" : {
            "${data.aws_s3_bucket.oidc_bucket.bucket_regional_domain_name}:aud" : "irsa",
            "${data.aws_s3_bucket.oidc_bucket.bucket_regional_domain_name}:sub" : "system:serviceaccount:kube-system:aws-lb-controller"
          }
        }
      }
    ]
  })

  permissions_boundary = var.permissions_boundary
}

resource "aws_iam_role_policy_attachment" "aws_lb_controller_iam_attachment" {
  role       = aws_iam_role.aws_lb_controller_role.name
  policy_arn = aws_iam_policy.aws_lb_controller_policy.arn
}