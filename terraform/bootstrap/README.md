This folder contains the infrastructure required to bootstrap the UDS Prod environment.  This includes:
- S3 state bucket
- DynamoDB Table for state lock
- GitHub integration role

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0, < 1.6.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.21.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_github_oidc_provider"></a> [github\_oidc\_provider](#module\_github\_oidc\_provider) | terraform-aws-modules/iam/aws//modules/iam-github-oidc-provider | 5.30.0 |
| <a name="module_github_oidc_role"></a> [github\_oidc\_role](#module\_github\_oidc\_role) | terraform-aws-modules/iam/aws//modules/iam-github-oidc-role | 5.30.0 |
| <a name="module_lock_table"></a> [lock\_table](#module\_lock\_table) | terraform-aws-modules/dynamodb-table/aws | 3.3.0 |
| <a name="module_state_bucket"></a> [state\_bucket](#module\_state\_bucket) | terraform-aws-modules/s3-bucket/aws | 3.15.1 |

## Resources

| Name | Type |
|------|------|
| [aws_kms_key.dynamodb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.objects](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Deployment environment (e.g. 'prod' or 'staging') | `string` | n/a | yes |
| <a name="input_github_policies"></a> [github\_policies](#input\_github\_policies) | Policies to attach to the IAM role in `{'static_name' = 'policy_arn'}` format | `map(string)` | `{}` | no |
| <a name="input_permissions_boundary"></a> [permissions\_boundary](#input\_permissions\_boundary) | IAM permissions boundary ARN | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region to deploy into | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_github_role_arn"></a> [github\_role\_arn](#output\_github\_role\_arn) | ARN for the GitHub Role |
| <a name="output_lock_table_id"></a> [lock\_table\_id](#output\_lock\_table\_id) | ID of the DynamoDB table |
| <a name="output_state_bucket_id"></a> [state\_bucket\_id](#output\_state\_bucket\_id) | Backend state bucket name |
<!-- END_TF_DOCS -->