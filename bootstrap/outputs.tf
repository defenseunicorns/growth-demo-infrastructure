output "lock_table_id" {
  description = "D of the DynamoDB table"
  value       = module.lock_table.dynamodb_table_id
}

output "state_bucket_id" {
  description = "Backend state bucket name"
  value = module.state_bucket.s3_bucket_id
}
