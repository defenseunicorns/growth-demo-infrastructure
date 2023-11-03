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
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 5.0 |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_rke2"></a> [rke2](#module\_rke2) | github.com/rancherfederal/rke2-aws-tf | v2.4.0 |
| <a name="module_rke2_agents"></a> [rke2\_agents](#module\_rke2\_agents) | github.com/rancherfederal/rke2-aws-tf//modules/agent-nodepool | v2.4.0 |

## Resources

| Name | Type |
|------|------|
| [aws_security_group_rule.quickstart_ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [local_file.ssh_pem](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [tls_private_key.ssh](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_subnets.private_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_subnets.public_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_agent_asg_desired"></a> [agent\_asg\_desired](#input\_agent\_asg\_desired) | ASG desired config for agent nodepool | `number` | `2` | no |
| <a name="input_agent_asg_max"></a> [agent\_asg\_max](#input\_agent\_asg\_max) | ASG max config for agent nodepool | `number` | `2` | no |
| <a name="input_agent_asg_min"></a> [agent\_asg\_min](#input\_agent\_asg\_min) | ASG minimum config for agent nodepool | `number` | `2` | no |
| <a name="input_agent_extra_block_device_mappings"></a> [agent\_extra\_block\_device\_mappings](#input\_agent\_extra\_block\_device\_mappings) | n/a | `list(map(string))` | `[]` | no |
| <a name="input_agent_instance_type"></a> [agent\_instance\_type](#input\_agent\_instance\_type) | Instance type for agents | `string` | `"m5.2xlarge"` | no |
| <a name="input_enable_ssh"></a> [enable\_ssh](#input\_enable\_ssh) | RKE2 | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Deployment environment (e.g. 'prod' or 'staging') | `string` | n/a | yes |
| <a name="input_num_rke2_servers"></a> [num\_rke2\_servers](#input\_num\_rke2\_servers) | Number of servers to create | `number` | `3` | no |
| <a name="input_permissions_boundary"></a> [permissions\_boundary](#input\_permissions\_boundary) | The ARN of the Permissions Boundary | `string` | `null` | no |
| <a name="input_public_access"></a> [public\_access](#input\_public\_access) | Setting this to true will put the nodes in public subnets and make the controlplane external. | `bool` | `false` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region to deploy into | `string` | n/a | yes |
| <a name="input_rke2_ami"></a> [rke2\_ami](#input\_rke2\_ami) | ID of the RKE2 AMI to use for the cluster | `string` | n/a | yes |
| <a name="input_server_extra_block_device_mappings"></a> [server\_extra\_block\_device\_mappings](#input\_server\_extra\_block\_device\_mappings) | n/a | `list(map(string))` | `[]` | no |
| <a name="input_server_instance_type"></a> [server\_instance\_type](#input\_server\_instance\_type) | Instance type for servers | `string` | `"t3.medium"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kubeconfig_path"></a> [kubeconfig\_path](#output\_kubeconfig\_path) | Path to kubeconfig in S3 |
<!-- END_TF_DOCS -->
