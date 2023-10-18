#######################################
# Backend State Bucket
#######################################

resource "aws_kms_key" "objects" {
  description             = "KMS key is used to encrypt bucket objects"
  deletion_window_in_days = 7
}

module "state_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  # TODO: add renovate
  version = "3.15.1"

  bucket_prefix = "uds-${var.stage}-state-"

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = aws_kms_key.objects.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  versioning = {
    status     = true
    mfa_delete = false
  }

  logging = {
    target_bucket = module.state_bucket.s3_bucket_id
    target_prefix = "log/"
  }
}

#######################################
# Backend State Locks
#######################################

resource "aws_kms_key" "dynamodb" {
  enable_key_rotation     = true
  description             = "KMS key used to encrypt DynamoDB Table"
  deletion_window_in_days = 7
}

module "lock_table" {
  source = "terraform-aws-modules/dynamodb-table/aws"
  # TODO: add renovate
  version = "3.3.0"

  name     = "uds-state-lock"
  hash_key = "LockID"

  attributes = [
    {
      name = "LockID"
      type = "S"
    }
  ]

  point_in_time_recovery_enabled = true

  server_side_encryption_enabled     = true
  server_side_encryption_kms_key_arn = aws_kms_key.dynamodb.arn
}

#######################################
# GitHub Role
#######################################

module "github_oidc_provider" {
  source = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-provider"
  # TODO: add renovate
  version = "5.30.0"
}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

module "github_oidc_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-role"
  # TODO: add renovate
  version = "5.30.0"

  name                     = "GitHubActionsAssumeWithWebIdentity"
  description              = "IAM Role that GitHub Actions assumes to perform actions on AWS"
  force_detach_policies    = true
  max_session_duration     = 28800 # 8 hours
  permissions_boundary_arn = var.permissions_boundary
  policies                 = var.github_policies

  subjects = ["repo:defenseunicorns/uds-prod-infrastructure:*"]
}
