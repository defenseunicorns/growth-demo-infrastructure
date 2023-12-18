locals {
  resource_prefix = "uds-swf-${var.environment}-"
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
