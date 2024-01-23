data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs      = [for az_name in slice(data.aws_availability_zones.available.names, 0, min(length(data.aws_availability_zones.available.names), var.num_azs)) : az_name]
  vpc_name = "uds-${var.environment}"
  # NOTE: This needs to match the cluster name in ../cluster/rke2.tf
  cluster_name = "uds-${var.environment}"
}

resource "aws_eip" "tenant_gateway_eip" {
  count  = length(local.azs)
  domain = "vpc"
  tags = {
    Name = "${var.environment} - tenant gateway"
  }
}

resource "aws_eip" "passthrough_gateway_eip" {
  count  = length(local.azs)
  domain = "vpc"
  tags = {
    Name = "${var.environment} - passthrough gateway"
  }
}

module "vpc" {
  source = "git::https://github.com/defenseunicorns/terraform-aws-uds-vpc.git?ref=v0.1.0"

  name                  = local.vpc_name
  vpc_cidr              = var.cidr
  secondary_cidr_blocks = var.secondary_cidr_blocks
  azs                   = local.azs
  public_subnets        = [for k, v in module.vpc.azs : cidrsubnet(module.vpc.vpc_cidr_block, 5, k)]
  private_subnets       = [for k, v in module.vpc.azs : cidrsubnet(module.vpc.vpc_cidr_block, 5, k + 4)]
  database_subnets      = [for k, v in module.vpc.azs : cidrsubnet(module.vpc.vpc_cidr_block, 5, k + 8)]
  intra_subnets         = [for k, v in module.vpc.azs : cidrsubnet(element(module.vpc.vpc_secondary_cidr_blocks, 0), 5, k)]

  single_nat_gateway                = true
  enable_nat_gateway                = true
  create_database_subnet_group      = true
  vpc_flow_log_permissions_boundary = var.permissions_boundary

  public_subnet_tags = {
    "kubernetes.io/role/elb"                      = 1
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"             = 1
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }
}
