data "aws_eips" "tenant" {
  filter {
    name   = "tag:Name"
    values = ["${var.environment}*tenant*"]
  }
}

data "aws_eips" "passthrough" {
  filter {
    name   = "tag:Name"
    values = ["${var.environment}*passthrough*"]
  }
}

resource "local_sensitive_file" "uds_config" {
  filename = "uds-config.yaml"
  content  = <<EOY
options:
  architecture: amd64

variables:
  init:
    # Workaround for SELinux EBS issue - https://github.com/bottlerocket-os/bottlerocket/issues/2417
    registry_hpa_enable: false
    registry_pvc_size: 50Gi
  aws-lb-controller:
    cluster_name: "uds-${var.environment}"
    lb_role_arn: "${aws_iam_role.aws_lb_controller_role.arn}"
  uds-core:
    # These are escaped with commas to workaround a uds/zarf parsing issue (4x \ for terraform to print out 2x \ into the file)
    tenant_eip_allocations: "${join("\\\\,", data.aws_eips.tenant.allocation_ids)}"
    passthrough_eip_allocations: "${join("\\\\,", data.aws_eips.passthrough.allocation_ids)}"
EOY
}

resource "aws_secretsmanager_secret" "uds_config" {
  name                    = "uds-base-${var.environment}-uds-config"
  description             = "uds-base-${var.environment} UDS Config file"
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
  name = "${var.environment}-read-uds-base-secret"
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
