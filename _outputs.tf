
output "bucket" {
  description = "bucket resource"
  value       = aws_s3_bucket.storage
}

output "encyption_key" {
  description = "kms encryption key used to secure elements"
  value       = local.encryption_key
}
