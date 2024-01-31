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

# Gitlab Variables

variable "gitlab_bucket_names" {
  description = "List of buckets to create for GitLab"
  type        = list(string)
  default     = ["gitlab-artifacts", "gitlab-backups", "gitlab-ci-secure-files", "gitlab-dependency-proxy", "gitlab-lfs", "gitlab-mr-diffs", "gitlab-packages", "gitlab-pages", "gitlab-terraform-state", "gitlab-uploads", "gitlab-registry", "gitlab-runner-cache", "gitlab-tmp"]
}

variable "gitlab_kms_key_alias" {
  description = "KMS Key Alias name prefix"
  type        = string
  default     = "uds-gitlab"
}

variable "gitlab_db_name" {
  description = "Name of the GitLab database."
  type        = string
  default     = "gitlabdb"
}

variable "gitlab_namespace" {
  description = "Namespace GitLab is deployed to"
  type        = string
}

variable "elasticache_cluster_name" {
  description = "ElastiCache Cluster Name"
  type        = string
  default     = "uds-gitlab-cluster"
}

# Mattermost Variables

variable "mattermost_bucket_names" {
  description = "List of buckets to create for Mattermost"
  type        = list(string)
  default     = ["mattermost"]
}

variable "mattermost_kms_key_alias" {
  description = "KMS Key Alias name prefix"
  type        = string
  default     = "uds-mattermost"
}

variable "mattermost_db_name" {
  description = "Name of the Mattermost database."
  type        = string
  default     = "mattermost"
}

variable "mattermost_namespace" {
  description = "Namespace Mattermost is deployed to"
  type        = string
}

# Sonarqube Variables

variable "sonarqube_db_name" {
  description = "Name of the Sonarqube database."
  type        = string
  default     = "sonarqubedb"
}

# General S3 Variables

variable "force_destroy" {
  description = "Option to set force destroy"
  type        = bool
  default     = false
}

# UDS Config Variables

variable "recovery_window" {
  description = "Number of days to retain secret before permanent deletion"
  type        = number
  default     = 30
}
