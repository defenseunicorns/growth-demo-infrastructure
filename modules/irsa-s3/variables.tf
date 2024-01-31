variable "permissions_boundary" {
  description = "The ARN of the Permissions Boundary"
  type        = string
  default     = null
}

variable "environment" {
  description = "Deployment environment (e.g. 'prod' or 'staging')"
  type        = string
}

variable "region" {
  description = "The AWS region to deploy into"
  type        = string
}

variable "resource_prefix" {
  description = "Prefix for resources created"
  type        = string
}

variable "namespace" {
  description = "Namespace for the IAM S3 Bucket Role"
  type        = string
}

variable "bucket_names" {
  description = "List of buckets"
  type        = list(string)
  default     = []
}

variable "kms_key_arn" {
  description = "KMS Key ARN"
  type        = string
}

variable "serviceaccount_names" {
  description = "List of service accounts"
  type        = list(string)
  default     = ["gitlab-gitaly", "gitlab-sidekiq", "gitlab-toolbox", "gitlab-gitlab-exporter", "gitlab-registry", "gitlab-geo-logcursor", "gitlab-migrations", "gitlab-webservice", "gitlab-mailroom", "gitlab-gitlab-shell"]
}
