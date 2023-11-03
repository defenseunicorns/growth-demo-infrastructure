#
# Common
#
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
  description = "Deployment environment (e.g. 'prod' or 'staging'), used to construct VPC name and label other resources."
  type        = string
}

#
# Bastion
#
variable "create_bastion" {
  description = "Whether to create a bastion host"
  type        = bool
  default     = true
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
