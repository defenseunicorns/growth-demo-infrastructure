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

variable "pre_userdata_base_file" {
  description = "The path to the file containing the base pre_userdata"
  type        = string
  default     = "./templates/pre_userdata_base.sh.tpl"
}

variable "post_userdata_base_file" {
  description = "The path to the file containing the base post_userdata"
  type        = string
  default     = "./templates/post_userdata_base.sh"
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

variable "loki_namespace" {
  description = "Namespace Loki is deployed to"
  type        = string
}

variable "loki_bucket_names" {
  description = "List of buckets to create for Loki"
  type        = list(string)
  default     = ["loki-chunks", "loki-ruler", "loki-admin"]
}

variable "loki_kms_key_alias" {
  description = "KMS Key Alias name prefix"
  type        = string
  default     = "uds-loki"
}

variable "force_destroy" {
  description = "Option to set force destroy"
  type        = bool
  default     = false
}

#
# LFAI Configs for RKE2
#
variable "enable_lfai_agents" {
  description = "Whether to create RKE2 agents to support LFAI."
  type        = bool
  default     = false
}

variable "lfai_rke2_ami" {
  description = "ID of the RKE2 AMI to use for the LFAI nodes"
  type        = string
  default     = null
}

variable "lfai_agent_instance_type" {
  description = "Instance type for LFAI agents"
  type        = string
  default     = "p3.8xlarge"
}

variable "lfai_agent_asg_min" {
  description = "ASG minimum config for LFAI agent nodepool"
  type        = number
  default     = 1
}

variable "lfai_agent_asg_desired" {
  description = "ASG desired config for LFAI agent nodepool"
  type        = number
  default     = 1
}

variable "lfai_agent_asg_max" {
  description = "ASG max config for LFAI agent nodepool"
  type        = number
  default     = 1
}

variable "lfai_agent_block_device_size" {
  description = "Size (GB) for the primary block device on LFAI agent nodes"
  type        = number
  default     = 100
}

variable "lfai_agent_extra_block_device_mappings" {
  type    = list(map(string))
  default = []
}

variable "lfai_pre_userdata_additional_file" {
  description = "The path to the file containing the additional lfai pre_userdata"
  type        = string
  default     = "./templates/pre_userdata_additional_lfai.sh"
}

# UDS Config Variables

variable "recovery_window" {
  description = "Number of days to retain secret before permanent deletion"
  type        = number
  default     = 30
}