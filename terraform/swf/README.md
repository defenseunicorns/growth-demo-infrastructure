# SWF

This deploys the Software Factory infrastructure for UDS environments.

New environments (dev, staging, prod, etc) must have:
- An environment setup in github (https://github.com/defenseunicorns/uds-prod-infrastructure/settings/environments) with these variables defined:
  - `AWS_REGION`: The AWS region to deploy into
  - `LOCK_TABLE`: The existing dynamodb table for tfstate lock
  - `STATE_BUCKET`: The existing bucket for tfstate storage
  - `PERMISSIONS_BOUNDARY`: The ARN for the permissions boundary in the AWS account
- An environment specific folder under the `env` folder. This folder must:
  - Be named with the same name as the environment
  - Have a `swf.tfvars` file under it that contains all variables necessary for deployment
- A VPC to deploy into (this is handled with the VPC terraform)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0, < 1.6.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | < 5.23 |
| <a name="requirement_local"></a> [local](#requirement\_local) | < 2.5 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.5.1 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | < 4.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | < 5.23 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.5.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_gitlab_db"></a> [gitlab\_db](#module\_gitlab\_db) | terraform-aws-modules/rds/aws | 6.1.1 |
| <a name="module_irsa-s3"></a> [irsa-s3](#module\_irsa-s3) | ../../modules/irsa-s3 | n/a |
| <a name="module_kms_key"></a> [kms\_key](#module\_kms\_key) | github.com/defenseunicorns/terraform-aws-uds-kms | v0.0.2 |
| <a name="module_s3_bucket"></a> [s3\_bucket](#module\_s3\_bucket) | terraform-aws-modules/s3-bucket/aws | 3.14.1 |

## Resources

| Name | Type |
|------|------|
| [aws_elasticache_replication_group.redis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_replication_group) | resource |
| [aws_elasticache_subnet_group.redis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_subnet_group) | resource |
| [aws_secretsmanager_secret.elasticache_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.gitlab_db_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.elasticache_secret_value](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.gitlab_db_secret_value](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group.rds_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.redis_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_ingress_rule.rds_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.redis_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [random_password.elasticache_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.gitlab_db_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_subnets.subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_names"></a> [bucket\_names](#input\_bucket\_names) | List of buckets to create | `list(string)` | <pre>[<br>  "gitlab-artifacts",<br>  "gitlab-backups",<br>  "gitlab-ci-secure-files",<br>  "gitlab-dependency-proxy",<br>  "gitlab-lfs",<br>  "gitlab-mr-diffs",<br>  "gitlab-packages",<br>  "gitlab-pages",<br>  "gitlab-terraform-state",<br>  "gitlab-uploads",<br>  "gitlab-registry",<br>  "gitlab-runner-cache",<br>  "gitlab-tmp"<br>]</pre> | no |
| <a name="input_elasticache_cluster_name"></a> [elasticache\_cluster\_name](#input\_elasticache\_cluster\_name) | ElastiCache Cluster Name | `string` | `"uds-gitlab-cluster"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Deployment environment (e.g. 'prod' or 'staging') | `string` | n/a | yes |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Option to set force destroy | `bool` | `false` | no |
| <a name="input_gitlab_db_name"></a> [gitlab\_db\_name](#input\_gitlab\_db\_name) | Name of the GitLab database. | `string` | `"gitlabdb"` | no |
| <a name="input_gitlab_kms_key_alias"></a> [gitlab\_kms\_key\_alias](#input\_gitlab\_kms\_key\_alias) | KMS Key Alias name prefix | `string` | `"uds-gitlab"` | no |
| <a name="input_recovery_window"></a> [recovery\_window](#input\_recovery\_window) | Number of days to retain secret before permanent deletion | `number` | `30` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region to deploy into | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
