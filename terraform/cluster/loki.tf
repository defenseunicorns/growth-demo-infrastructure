# S3 Buckets

## This will create a bucket for each name in `bucket_names`.
module "loki_s3_bucket" {
  for_each = toset(var.loki_bucket_names)

  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.14.1"

  # NOTE: need to keep track that the suffix for loki buckets is the environment
  bucket        = "uds-${each.key}-${var.environment}"
  force_destroy = var.force_destroy

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = module.loki_kms_key.kms_key_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

module "loki_irsa-s3" {
  source = "../../modules/irsa-s3"

  environment          = var.environment
  region               = var.region
  permissions_boundary = var.permissions_boundary
  resource_prefix      = local.resource_prefix
  namespace            = var.loki_namespace
  bucket_names         = var.loki_bucket_names
  kms_key_arn          = module.loki_kms_key.kms_key_arn
  serviceaccount_names = ["loki"]
}

module "loki_kms_key" {
  source = "github.com/defenseunicorns/terraform-aws-uds-kms?ref=v0.0.2"

  kms_key_alias_name_prefix = var.loki_kms_key_alias
  kms_key_deletion_window   = 7
  kms_key_description       = "Loki Key"
}
