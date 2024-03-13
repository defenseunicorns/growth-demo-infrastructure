# S3 Buckets

## This will create a bucket for each name in `bucket_names`.
module "mattermost_s3_bucket" {
  for_each = toset(var.mattermost_bucket_names)

  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.14.1"

  # NOTE: need to keep track that the suffix for mattermost buckets is the environment
  bucket        = "uds-${each.key}-${var.environment}"
  force_destroy = var.force_destroy

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = module.mattermost_kms_key.kms_key_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

module "mattermost_irsa-s3" {
  source = "../../modules/irsa-s3"

  environment          = var.environment
  region               = var.region
  permissions_boundary = var.permissions_boundary
  resource_prefix      = local.resource_prefix
  namespace            = var.mattermost_namespace
  bucket_names         = var.mattermost_bucket_names
  kms_key_arn          = module.mattermost_kms_key.kms_key_arn
  serviceaccount_names = ["mattermost"]
}

module "mattermost_kms_key" {
  source = "github.com/defenseunicorns/terraform-aws-uds-kms?ref=v0.0.2"

  kms_key_alias_name_prefix = var.mattermost_kms_key_alias
  kms_key_deletion_window   = 7
  kms_key_description       = "Mattermost Key"
}


# RDS

resource "random_password" "mattermost_db_password" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "mattermost_db_secret" {
  name                    = "${local.resource_prefix}mattermost-db-secret"
  description             = "Mattermost DB authentication token"
  recovery_window_in_days = var.recovery_window
}

resource "aws_secretsmanager_secret_version" "mattermost_db_secret_value" {
  depends_on    = [aws_secretsmanager_secret.mattermost_db_secret]
  secret_id     = aws_secretsmanager_secret.mattermost_db_secret.id
  secret_string = random_password.mattermost_db_password.result
}

module "mattermost_db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.1.1"

  identifier                     = "mattermost-db"
  instance_use_identifier_prefix = true

  allocated_storage       = 20
  backup_retention_period = 1
  backup_window           = "03:00-06:00"
  maintenance_window      = "Mon:00:00-Mon:03:00"

  engine               = "postgres"
  engine_version       = "15.5"
  major_engine_version = "15"
  family               = "postgres15"
  instance_class       = "db.t4g.large"

  db_name  = var.mattermost_db_name
  username = "mattermost"
  port     = "5432"

  subnet_ids                  = data.aws_subnets.subnets.ids
  db_subnet_group_name        = "uds-${var.environment}"
  manage_master_user_password = false
  password                    = random_password.mattermost_db_password.result

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}
