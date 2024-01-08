output "registry_role_arn" {
  value = aws_iam_role.s3_bucket_role["gitlab-registry"].arn
}

output "sidekiq_role_arn" {
  value = aws_iam_role.s3_bucket_role["gitlab-sidekiq"].arn
}

output "webservice_role_arn" {
  value = aws_iam_role.s3_bucket_role["gitlab-webservice"].arn
}

output "toolbox_role_arn" {
  value = aws_iam_role.s3_bucket_role["gitlab-toolbox"].arn
}
