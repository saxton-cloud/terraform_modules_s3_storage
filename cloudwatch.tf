resource "aws_cloudwatch_log_group" "storage_buffer" {
  name              = "${var.product_code}/${var.qualifier}/${var.subsystem}/${var.name}"
  retention_in_days = 365
  # kms_key_id        = local.encryption_key.arn
}
resource "aws_cloudwatch_log_stream" "storage_buffer" {
  name           = "storage_buffer"
  log_group_name = aws_cloudwatch_log_group.storage_buffer.name
}



resource "aws_cloudwatch_log_metric_filter" "crawler_events_processed" {
  count          = local.reporting_enabled ? 1 : 0
  name           = "${local.name_prefix}-${var.name}-crawler-bucket-event-count"
  pattern        = "[, level=\"INFO\",,,,, unique=\"unique\",events=\"events\", received=\"received\",,eventCount,,,target=\"target\",bucket=\"s3://${aws_s3_bucket.storage.bucket}\",...]"
  log_group_name = "/aws-glue/crawlers"

  metric_transformation {
    name      = "BucketEventCount"
    namespace = "${title(var.product_code)}/Crawler Metrics"
    value     = "$eventCount"
    unit      = "Count"
    dimensions = {
      Bucket    = "$bucket"
    }
  }
}
