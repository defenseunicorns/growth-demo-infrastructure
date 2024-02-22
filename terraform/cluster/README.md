# Cluster

This deploys the cluster stack (RKE2) for UDS environments.

New environments (dev, staging, prod, etc) must have:
- An environment setup in github (https://github.com/defenseunicorns/uds-prod-infrastructure/settings/environments) with these variables defined:
  - `AWS_REGION`: The AWS region to deploy into
  - `LOCK_TABLE`: The existing dynamodb table for tfstate lock
  - `STATE_BUCKET`: The existing bucket for tfstate storage
  - `PERMISSIONS_BOUNDARY`: The ARN for the permissions boundary in the AWS account
- An environment specific folder under the `env` folder. This folder must:
  - Be named with the same name as the environment
  - Have a `cluster.tfvars` file under it that contains all variables necessary for deployment
- A VPC to deploy into (this is handled with the VPC terraform)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0, < 1.6.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | < 5.23 |
| <a name="requirement_local"></a> [local](#requirement\_local) | < 2.5 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | < 4.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.22.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.4.1 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.5 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_lfai_rke2_agents"></a> [lfai\_rke2\_agents](#module\_lfai\_rke2\_agents) | github.com/rancherfederal/rke2-aws-tf//modules/agent-nodepool | v2.4.0 |
| <a name="module_loki_irsa-s3"></a> [loki\_irsa-s3](#module\_loki\_irsa-s3) | ../../modules/irsa-s3 | n/a |
| <a name="module_loki_kms_key"></a> [loki\_kms\_key](#module\_loki\_kms\_key) | github.com/defenseunicorns/terraform-aws-uds-kms | v0.0.2 |
| <a name="module_loki_s3_bucket"></a> [loki\_s3\_bucket](#module\_loki\_s3\_bucket) | terraform-aws-modules/s3-bucket/aws | 3.14.1 |
| <a name="module_rke2"></a> [rke2](#module\_rke2) | github.com/rancherfederal/rke2-aws-tf | v2.4.0 |
| <a name="module_rke2_agents"></a> [rke2\_agents](#module\_rke2\_agents) | github.com/rancherfederal/rke2-aws-tf//modules/agent-nodepool | v2.4.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.aws_lb_controller_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.aws_lb_controller_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.read_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.aws_lb_controller_iam_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_secretsmanager_secret.uds_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.uds_config_value](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group_rule.quickstart_ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [local_file.ssh_pem](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_sensitive_file.uds_config](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/sensitive_file) | resource |
| [tls_private_key.ssh](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eips.passthrough](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eips) | data source |
| [aws_eips.tenant](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eips) | data source |
| [aws_iam_role.bastion-role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_role) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_s3_bucket.oidc_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) | data source |
| [aws_subnets.private_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_subnets.public_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_agent_asg_desired"></a> [agent\_asg\_desired](#input\_agent\_asg\_desired) | ASG desired config for agent nodepool | `number` | `2` | no |
| <a name="input_agent_asg_max"></a> [agent\_asg\_max](#input\_agent\_asg\_max) | ASG max config for agent nodepool | `number` | `2` | no |
| <a name="input_agent_asg_min"></a> [agent\_asg\_min](#input\_agent\_asg\_min) | ASG minimum config for agent nodepool | `number` | `2` | no |
| <a name="input_agent_block_device_size"></a> [agent\_block\_device\_size](#input\_agent\_block\_device\_size) | Size (GB) for the primary block device on agent nodes | `number` | `100` | no |
| <a name="input_agent_extra_block_device_mappings"></a> [agent\_extra\_block\_device\_mappings](#input\_agent\_extra\_block\_device\_mappings) | n/a | `list(map(string))` | `[]` | no |
| <a name="input_agent_instance_type"></a> [agent\_instance\_type](#input\_agent\_instance\_type) | Instance type for agents | `string` | `"m5.2xlarge"` | no |
| <a name="input_enable_lfai_agents"></a> [enable\_lfai\_agents](#input\_enable\_lfai\_agents) | Whether to create RKE2 agents to support LFAI. | `bool` | `false` | no |
| <a name="input_enable_ssh"></a> [enable\_ssh](#input\_enable\_ssh) | RKE2 | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Deployment environment (e.g. 'prod' or 'staging') | `string` | n/a | yes |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Option to set force destroy | `bool` | `false` | no |
| <a name="input_lfai_agent_asg_desired"></a> [lfai\_agent\_asg\_desired](#input\_lfai\_agent\_asg\_desired) | ASG desired config for LFAI agent nodepool | `number` | `1` | no |
| <a name="input_lfai_agent_asg_max"></a> [lfai\_agent\_asg\_max](#input\_lfai\_agent\_asg\_max) | ASG max config for LFAI agent nodepool | `number` | `1` | no |
| <a name="input_lfai_agent_asg_min"></a> [lfai\_agent\_asg\_min](#input\_lfai\_agent\_asg\_min) | ASG minimum config for LFAI agent nodepool | `number` | `1` | no |
| <a name="input_lfai_agent_block_device_size"></a> [lfai\_agent\_block\_device\_size](#input\_lfai\_agent\_block\_device\_size) | Size (GB) for the primary block device on LFAI agent nodes | `number` | `100` | no |
| <a name="input_lfai_agent_extra_block_device_mappings"></a> [lfai\_agent\_extra\_block\_device\_mappings](#input\_lfai\_agent\_extra\_block\_device\_mappings) | n/a | `list(map(string))` | `[]` | no |
| <a name="input_lfai_agent_instance_type"></a> [lfai\_agent\_instance\_type](#input\_lfai\_agent\_instance\_type) | Instance type for LFAI agents | `string` | `"p3.8xlarge"` | no |
| <a name="input_lfai_pre_userdata_additional_file"></a> [lfai\_pre\_userdata\_additional\_file](#input\_lfai\_pre\_userdata\_additional\_file) | The path to the file containing the additional lfai pre\_userdata | `string` | `"./templates/pre_userdata_additional_lfai.sh"` | no |
| <a name="input_lfai_rke2_ami"></a> [lfai\_rke2\_ami](#input\_lfai\_rke2\_ami) | ID of the RKE2 AMI to use for the LFAI nodes | `string` | `null` | no |
| <a name="input_loki_bucket_names"></a> [loki\_bucket\_names](#input\_loki\_bucket\_names) | List of buckets to create for Loki | `list(string)` | <pre>[<br>  "loki"<br>]</pre> | no |
| <a name="input_loki_kms_key_alias"></a> [loki\_kms\_key\_alias](#input\_loki\_kms\_key\_alias) | KMS Key Alias name prefix | `string` | `"uds-loki"` | no |
| <a name="input_loki_kms_key_arn"></a> [loki\_kms\_key\_arn](#input\_loki\_kms\_key\_arn) | KMS Key ARN if known, if not, will be generated | `string` | `null` | no |
| <a name="input_loki_namespace"></a> [loki\_namespace](#input\_loki\_namespace) | Namespace Loki is deployed to | `string` | n/a | yes |
| <a name="input_num_rke2_servers"></a> [num\_rke2\_servers](#input\_num\_rke2\_servers) | Number of servers to create | `number` | `3` | no |
| <a name="input_permissions_boundary"></a> [permissions\_boundary](#input\_permissions\_boundary) | The ARN of the Permissions Boundary | `string` | `null` | no |
| <a name="input_post_userdata_base_file"></a> [post\_userdata\_base\_file](#input\_post\_userdata\_base\_file) | The path to the file containing the base post\_userdata | `string` | `"./templates/post_userdata_base.sh"` | no |
| <a name="input_pre_userdata_base_file"></a> [pre\_userdata\_base\_file](#input\_pre\_userdata\_base\_file) | The path to the file containing the base pre\_userdata | `string` | `"./templates/pre_userdata_base.sh.tpl"` | no |
| <a name="input_public_access"></a> [public\_access](#input\_public\_access) | Setting this to true will put the nodes in public subnets and make the controlplane external. | `bool` | `false` | no |
| <a name="input_recovery_window"></a> [recovery\_window](#input\_recovery\_window) | Number of days to retain secret before permanent deletion | `number` | `30` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region to deploy into | `string` | n/a | yes |
| <a name="input_rke2_ami"></a> [rke2\_ami](#input\_rke2\_ami) | ID of the RKE2 AMI to use for the cluster | `string` | n/a | yes |
| <a name="input_server_block_device_size"></a> [server\_block\_device\_size](#input\_server\_block\_device\_size) | Size (GB) for the primary block device on server nodes | `number` | `100` | no |
| <a name="input_server_extra_block_device_mappings"></a> [server\_extra\_block\_device\_mappings](#input\_server\_extra\_block\_device\_mappings) | n/a | `list(map(string))` | `[]` | no |
| <a name="input_server_instance_type"></a> [server\_instance\_type](#input\_server\_instance\_type) | Instance type for servers | `string` | `"t3.medium"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kubeconfig_path"></a> [kubeconfig\_path](#output\_kubeconfig\_path) | Path to kubeconfig in S3 |
<!-- END_TF_DOCS -->
