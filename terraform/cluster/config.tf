terraform {
  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "< 4.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "< 2.5"
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
    }
  }
}
