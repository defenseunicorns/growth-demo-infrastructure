locals {
  shortenv = var.environment == "burn-the-boats" ? "btb" : var.environment

  #cluster_name = "uds-${local.shortenv}-cluster"

  resource_prefix = "uds-swf-${local.shortenv}-"
}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["uds-${var.environment}"]
  }
}

data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
}
