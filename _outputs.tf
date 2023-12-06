
output "bucket" {
  description = "bucket resource"
  value       = aws_s3_bucket.storage
}

output "encyption_key" {
  description = "kms encryption key used to secure elements"
  value       = local.encryption_key
}

output "buffer" {
  description = "when configured, returns the firehose serving as the bucket's buffer - otherwise null"
  value       = length(aws_kinesis_firehose_delivery_stream.storage_buffer) > 0 ? aws_kinesis_firehose_delivery_stream.storage_buffer[0] : null
}
