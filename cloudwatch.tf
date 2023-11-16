resource "aws_cloudwatch_log_group" "storage_buffer" {
  name              = "${var.product_code}/${var.qualifier}/${var.subsystem}/${var.name}"
  retention_in_days = 365
  # kms_key_id        = local.encryption_key.arn
}
resource "aws_cloudwatch_log_stream" "storage_buffer" {
  name           = "storage_buffer"
  log_group_name = aws_cloudwatch_log_group.storage_buffer.name
}
