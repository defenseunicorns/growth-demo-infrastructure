resource "local_sensitive_file" "uds_config" {
  filename = "uds-config.yaml"
  content  = <<EOY
shared:
  bucket_suffix: "-${var.environment}"

variables:
  swf-deps-aws:
    gitlab_db_password: "${random_password.gitlab_db_password.result}"
    sonarqube_db_password: "${random_password.sonarqube_db_password.result}"
    redis_password: "${random_password.elasticache_password.result}"
    region: "${var.region}"
  gitlab:
    gitlab_db_endpoint: "${element(split(":", module.gitlab_db.db_instance_endpoint), 0)}"
    gitlab_redis_endpoint: "${aws_elasticache_replication_group.redis.primary_endpoint_address}"
    gitlab_redis_scheme: "rediss"
    registry_role_arn: "${module.gitlab_irsa-s3.bucket_roles["gitlab-registry"].arn}"
    sidekiq_role_arn: "${module.gitlab_irsa-s3.bucket_roles["gitlab-sidekiq"].arn}"
    webservice_role_arn: "${module.gitlab_irsa-s3.bucket_roles["gitlab-webservice"].arn}"
    toolbox_role_arn: "${module.gitlab_irsa-s3.bucket_roles["gitlab-toolbox"].arn}"
  sonarqube:
    sonarqube_db_endpoint: "${element(split(":", module.sonarqube_db.db_instance_endpoint), 0)}"
  mattermost:
    mattermost_db_endpoint: "${element(split(":", module.mattermost_db.db_instance_endpoint), 0)}"
    mattermost_db_password: "${random_password.mattermost_db_password.result}"
    mattermost_bucket: "uds-mattermost-${var.environment}"
    mattermost_region: "${var.region}"
    mattermost_s3_endpoint: "s3.${var.region}.amazonaws.com"
    mattermost_role_arn: "${module.mattermost_irsa-s3.bucket_roles["mattermost"].arn}"
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

data "aws_iam_role" "bastion-role" {
  name = "${var.environment}-bastion"
}

resource "aws_iam_role_policy" "read_secret" {
  name = "${var.environment}-read-uds-swf-secret"
  role = data.aws_iam_role.bastion-role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ]
        Effect   = "Allow"
        Resource = aws_secretsmanager_secret.uds_config.arn
      },
      {
        Effect   = "Allow"
        Action   = "secretsmanager:ListSecrets"
        Resource = "*"
      },
    ]
  })
}
