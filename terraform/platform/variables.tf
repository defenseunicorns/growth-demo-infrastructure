variable "create_bastion" {
  description = "Whether to create a bastion host"
  type        = bool
  default     = true
}

variable "enable_ssh" {
  type    = bool
  default = false
}

variable "permissions_boundary" {
  description = "The ARN of the Permissions Boundary"
  type        = string
  default     = null
}

variable "region" {
  description = "The AWS region to deploy into"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. 'prod' or 'staging')"
  type        = string
}

variable "public_access" {
  description = "Setting this to true will put the nodes in public subnets and make the controlplane external."
  type        = bool
  default     = false
}

#
# VPC
#
variable "cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "num_azs" {
  description = "The number of AZs to attempt to use in a region."
  type        = number
  default     = 2
}

variable "secondary_cidr_blocks" {
  description = "Secondary CIDR block used to optimize node and pod IP addresses.  See: https://aws.amazon.com/blogs/containers/optimize-ip-addresses-usage-by-pods-in-your-amazon-eks-cluster/"
  type        = list(string)
  default     = []
}

variable "vpc_flow_log_permissions_boundary" {
  description = "The ARN of the Permissions Boundary for the VPC Flow Log IAM Role"
  type        = string
  default     = null
}

variable "vpc_name" {
  description = "Name to identify resources."
  type        = string
  default     = "uds-prod"
}

#
# RKE2 Cluster
#
variable "rke2_ami" {
  description = "ID of the RKE2 AMI to use for the cluster"
  type        = string
}

variable "num_rke2_servers" {
  description = "Number of servers to create"
  type        = number
  default     = 3
}

variable "agent_asg_min" {
  description = "ASG minimum config for agent nodepool"
  type        = number
  default     = 2
}

variable "agent_asg_desired" {
  description = "ASG desired config for agent nodepool"
  type        = number
  default     = 2
}

variable "agent_asg_max" {
  description = "ASG max config for agent nodepool"
  type        = number
  default     = 2
}
