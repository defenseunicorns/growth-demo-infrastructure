# RDS

resource "random_password" "sonarqube_db_password" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "sonarqube_db_secret" {
  name                    = "${local.resource_prefix}sonarqube-db-secret"
  description             = "Sonarqube DB authentication token"
  recovery_window_in_days = var.recovery_window
}

resource "aws_secretsmanager_secret_version" "sonarqube_db_secret_value" {
  depends_on    = [aws_secretsmanager_secret.sonarqube_db_secret]
  secret_id     = aws_secretsmanager_secret.sonarqube_db_secret.id
  secret_string = random_password.sonarqube_db_password.result
}

module "sonarqube_db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.1.1"

  identifier                     = "sonarqube-db"
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

  db_name  = var.sonarqube_db_name
  username = "sonarqube"
  port     = "5432"

  subnet_ids                  = data.aws_subnets.subnets.ids
  db_subnet_group_name        = "uds-${var.environment}"
  manage_master_user_password = false
  password                    = random_password.sonarqube_db_password.result

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}

