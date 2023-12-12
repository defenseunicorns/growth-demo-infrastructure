# S3 Buckets

## This will create a bucket for each name in `bucket_names`.
module "s3_bucket" {
  for_each = toset(var.bucket_names)

  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.14.1"

  # NOTE: need to keep track that the suffix for gitlab buckets is the environment
  bucket        = "uds-${each.key}-${var.environment}"
  force_destroy = var.force_destroy

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = module.kms_key.kms_key_arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

module "irsa-s3" {
  source = "../../modules/irsa-s3"

  environment          = var.environment
  region               = var.region
  permissions_boundary = var.permissions_boundary
  resource_prefix      = local.resource_prefix
  bucket_names         = var.bucket_names
  kms_key_arn          = module.kms_key.kms_key_arn
}

module "kms_key" {
  source = "github.com/defenseunicorns/terraform-aws-uds-kms?ref=v0.0.2"

  kms_key_alias_name_prefix = var.gitlab_kms_key_alias
  kms_key_deletion_window   = 7
  kms_key_description       = "GitLab Key"
}


# RDS

resource "random_password" "gitlab_db_password" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "gitlab_db_secret" {
  name                    = "${local.resource_prefix}gitlab-db-secret"
  description             = "uds-swf-${local.shortenv} Gitlab DB authentication token"
  recovery_window_in_days = var.recovery_window
}

resource "aws_secretsmanager_secret_version" "gitlab_db_secret_value" {
  depends_on    = [aws_secretsmanager_secret.gitlab_db_secret]
  secret_id     = aws_secretsmanager_secret.gitlab_db_secret.id
  secret_string = random_password.gitlab_db_password.result
}

module "gitlab_db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.1.1"

  identifier                     = "gitlab-db"
  instance_use_identifier_prefix = true

  allocated_storage       = 20
  backup_retention_period = 1
  backup_window           = "03:00-06:00"
  maintenance_window      = "Mon:00:00-Mon:03:00"

  engine               = "postgres"
  engine_version       = "15.3"
  major_engine_version = "15"
  family               = "postgres15"
  instance_class       = "db.t4g.large"

  db_name  = var.gitlab_db_name
  username = "gitlab"
  port     = "5432"

  subnet_ids = data.aws_subnets.subnets.ids

  manage_master_user_password = false
  password                    = random_password.gitlab_db_password.result

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}

resource "aws_security_group" "rds_sg" {
  vpc_id = data.aws_vpc.vpc.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_vpc_security_group_ingress_rule" "rds_ingress" {
  security_group_id = aws_security_group.rds_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 0
  to_port     = 5432
}


# Elasticache

resource "random_password" "elasticache_password" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "elasticache_secret" {
  name                    = "${local.resource_prefix}elasticache-secret"
  description             = "uds-swf-${local.shortenv} Elasticache authentication token"
  recovery_window_in_days = var.recovery_window
}

resource "aws_secretsmanager_secret_version" "elasticache_secret_value" {
  depends_on    = [aws_secretsmanager_secret.elasticache_secret]
  secret_id     = aws_secretsmanager_secret.elasticache_secret.id
  secret_string = random_password.elasticache_password.result
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id = "${var.elasticache_cluster_name}-${local.shortenv}"
  description          = "Redis Replication Group for GitLab"

  subnet_group_name = aws_elasticache_subnet_group.redis.name

  node_type            = "cache.r6g.large"
  engine_version       = "7.0"
  parameter_group_name = "default.redis7"
  auth_token           = random_password.elasticache_password.result
  port                 = 6379

  num_cache_clusters = 2

  automatic_failover_enabled = true
  multi_az_enabled           = true

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  security_group_ids = [aws_security_group.redis_sg.id]
}

resource "aws_elasticache_subnet_group" "redis" {
  name       = "redis-cache-subnet"
  subnet_ids = data.aws_subnets.subnets.ids
}

resource "aws_security_group" "redis_sg" {
  vpc_id = data.aws_vpc.vpc.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_vpc_security_group_ingress_rule" "redis_ingress" {
  security_group_id = aws_security_group.redis_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 0
  to_port     = 6379
}
