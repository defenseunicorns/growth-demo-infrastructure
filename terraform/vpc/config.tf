terraform {
  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.26.0, < 5.30.0"
    }
  }

  required_version = ">= 1.0.0, < 1.6.0"
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      terraform   = true
      repository  = "github.com/defenseunicorns/uds-prod-infrastructure"
      environment = var.environment
      // Add permissions boundary tag to handle all roles in a simple way
      PermissionsBoundary = split("/", var.permissions_boundary)[1]
    }
  }
}
