variable "region" {
  description = "The AWS region to deploy into"
  type        = string
}

variable "stage" {
  description = "Environment stage (e.g. 'prod' or 'staging')"
  type        = string
}
