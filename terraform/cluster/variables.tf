#
# Common
#
variable "region" {
  description = "The AWS region to deploy into"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. 'prod' or 'staging')"
  type        = string
}

#
# RKE2
#
variable "enable_ssh" {
  type    = bool
  default = false
}

variable "permissions_boundary" {
  description = "The ARN of the Permissions Boundary"
  type        = string
  default     = null
}


variable "public_access" {
  description = "Setting this to true will put the nodes in public subnets and make the controlplane external."
  type        = bool
  default     = false
}

variable "rke2_ami" {
  description = "ID of the RKE2 AMI to use for the cluster"
  type        = string
}

variable "num_rke2_servers" {
  description = "Number of servers to create"
  type        = number
  default     = 3
}

variable "server_instance_type" {
  description = "Instance type for servers"
  type        = string
  default     = "t3.medium"
}

variable "server_block_device_size" {
  description = "Size (GB) for the primary block device on server nodes"
  type        = number
  default     = 100
}

variable "server_extra_block_device_mappings" {
  type    = list(map(string))
  default = []
}

variable "agent_instance_type" {
  description = "Instance type for agents"
  type        = string
  default     = "m5.2xlarge"
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

variable "agent_block_device_size" {
  description = "Size (GB) for the primary block device on agent nodes"
  type        = number
  default     = 100
}

variable "agent_extra_block_device_mappings" {
  type    = list(map(string))
  default = []
}
