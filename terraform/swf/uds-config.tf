resource "local_sensitive_file" "uds_config" {
  filename = "uds-config.yaml"
  content  = <<EOY
variables:
  swf-deps-aws:
    postgres_db_password: "${random_password.gitlab_db_password.result}"
    redis_password: "${random_password.elasticache_password.result}"
  gitlab:
    postgres_db_endpoint: "${module.gitlab_db.db_instance_endpoint}"
    gitlab_redis_endpoint: "${aws_elasticache_replication_group.redis.primary_endpoint_address}"
EOY
}

resource "aws_secretsmanager_secret" "uds_config" {
  name                    = "${local.resource_prefix}uds-config"
  description             = "uds-swf-${var.environment} UDS Config file"
  recovery_window_in_days = var.recovery_window
}

resource "aws_secretsmanager_secret_version" "uds_config_value" {
  depends_on    = [aws_secretsmanager_secret.uds_config, local_sensitive_file.uds_config]
  secret_id     = aws_secretsmanager_secret.uds_config.id
  secret_string = local_sensitive_file.uds_config.content
}
