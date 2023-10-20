variable "cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "num_azs" {
  description = "The number of AZs to attempt to use in a region."
  type        = number
  default     = 2
}

variable "region" {
  description = "The AWS region to deploy into"
  type        = string
}

variable "secondary_cidr_blocks" {
  description = "Secondary CIDR block used to optimize node and pod IP addresses.  See: https://aws.amazon.com/blogs/containers/optimize-ip-addresses-usage-by-pods-in-your-amazon-eks-cluster/"
  type        = list(string)
  default     = []
}

variable "stage" {
  description = "Environment stage (e.g. 'prod' or 'staging')"
  type        = string
}

variable "vpc_flow_log_permissions_boundary" {
  description = "The ARN of the Permissions Boundary for the VPC Flow Log IAM Role"
  type        = string
  default     = null
}

variable "vpc_name" {
  description = "Name to identify resources."
  type        = string
  default     = "uds-software-factory"
}
