# Platform

This deploys the VPC and cluster for UDS Prod.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0, < 1.6.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.22.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.4.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.4 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_rke2"></a> [rke2](#module\_rke2) | github.com/rancherfederal/rke2-aws-tf | v2.4.0 |
| <a name="module_rke2_agents"></a> [rke2\_agents](#module\_rke2\_agents) | github.com/rancherfederal/rke2-aws-tf//modules/agent-nodepool | v2.4.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | git::https://github.com/defenseunicorns/terraform-aws-uds-vpc.git | v0.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.bastion-host-instance-profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.bastion-host-instance-role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_instance.bastion_host](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_security_group.bastion_host_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.quickstart_ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [local_file.ssh_pem](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [tls_private_key.ssh](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_ami.amazon-linux-2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_agent_asg_desired"></a> [agent\_asg\_desired](#input\_agent\_asg\_desired) | ASG desired config for agent nodepool | `number` | `2` | no |
| <a name="input_agent_asg_max"></a> [agent\_asg\_max](#input\_agent\_asg\_max) | ASG max config for agent nodepool | `number` | `2` | no |
| <a name="input_agent_asg_min"></a> [agent\_asg\_min](#input\_agent\_asg\_min) | ASG minimum config for agent nodepool | `number` | `2` | no |
| <a name="input_cidr"></a> [cidr](#input\_cidr) | CIDR block for the VPC | `string` | n/a | yes |
| <a name="input_create_bastion"></a> [create\_bastion](#input\_create\_bastion) | Whether to create a bastion host | `bool` | `true` | no |
| <a name="input_enable_ssh"></a> [enable\_ssh](#input\_enable\_ssh) | n/a | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Deployment environment (e.g. 'prod' or 'staging') | `string` | n/a | yes |
| <a name="input_num_azs"></a> [num\_azs](#input\_num\_azs) | The number of AZs to attempt to use in a region. | `number` | `2` | no |
| <a name="input_num_rke2_servers"></a> [num\_rke2\_servers](#input\_num\_rke2\_servers) | Number of servers to create | `number` | `3` | no |
| <a name="input_permissions_boundary"></a> [permissions\_boundary](#input\_permissions\_boundary) | The ARN of the Permissions Boundary | `string` | `null` | no |
| <a name="input_public_access"></a> [public\_access](#input\_public\_access) | Setting this to true will put the nodes in public subnets and make the controlplane external. | `bool` | `false` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region to deploy into | `string` | n/a | yes |
| <a name="input_rke2_ami"></a> [rke2\_ami](#input\_rke2\_ami) | ID of the RKE2 AMI to use for the cluster | `string` | n/a | yes |
| <a name="input_secondary_cidr_blocks"></a> [secondary\_cidr\_blocks](#input\_secondary\_cidr\_blocks) | Secondary CIDR block used to optimize node and pod IP addresses.  See: https://aws.amazon.com/blogs/containers/optimize-ip-addresses-usage-by-pods-in-your-amazon-eks-cluster/ | `list(string)` | `[]` | no |
| <a name="input_vpc_flow_log_permissions_boundary"></a> [vpc\_flow\_log\_permissions\_boundary](#input\_vpc\_flow\_log\_permissions\_boundary) | The ARN of the Permissions Boundary for the VPC Flow Log IAM Role | `string` | `null` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | Name to identify resources. | `string` | `"uds-prod"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kubeconfig_path"></a> [kubeconfig\_path](#output\_kubeconfig\_path) | Path to kubeconfig in S3 |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
<!-- END_TF_DOCS -->
