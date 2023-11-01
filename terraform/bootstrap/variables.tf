variable "github_policies" {
  description = "Policies to attach to the IAM role in `{'static_name' = 'policy_arn'}` format"
  type        = map(string)
  default     = {}
}

variable "permissions_boundary" {
  description = "IAM permissions boundary ARN"
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
