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

// Keypair secrets variables

variable "recovery_window" {
  description = "Number of days to retain secret before permanent deletion"
  type        = number
  default     = 30
}

// OIDC Bucket variables
variable "force_destroy" {
  description = "Whether to force destroy the bucket or not"
  type        = bool
  default     = false
}

// OIDC IAM Provider variables

variable "client_id_list" {
  description = "Comma separated list of client IDs (audiences) for the provider"
  type        = list(string)
  default     = ["irsa"]
}
