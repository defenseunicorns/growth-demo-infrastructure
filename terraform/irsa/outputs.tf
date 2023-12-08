output "oidc_provider" {
  value = "https://${module.oidc_bucket.s3_bucket_bucket_regional_domain_name}"
}

output "public_key_aws_secret" {
  value = aws_secretsmanager_secret.public_key.id
}

output "private_key_aws_secret" {
  value = aws_secretsmanager_secret.private_key.id
}
