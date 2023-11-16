locals {
  buffered_dynamic_partitioning_enabled = length(regexall("!\\{.*\\}", join("", [var.firehose_config.prefix, var.firehose_config.error_output_prefix]))) > 0
  buffered_min_buffering_size           = local.buffered_dynamic_partitioning_enabled ? 64 : 1
}
resource "aws_kinesis_firehose_delivery_stream" "storage_buffer" {
  count       = local.buffered ? 1 : 0
  name        = "${local.name_prefix}-${var.name}-buffer"
  destination = "extended_s3"


  dynamic "kinesis_source_configuration" {
    for_each = var.firehose_config.source_kinesis_stream_arn != null ? [1] : []
    content {
      kinesis_stream_arn = var.firehose_config.source_kinesis_stream_arn
      role_arn           = aws_iam_role.storage_buffer[0].arn
    }
  }

  extended_s3_configuration {
    role_arn   = aws_iam_role.storage_buffer[0].arn
    bucket_arn = aws_s3_bucket.storage.arn

    buffering_size     = max(var.firehose_config.buffering_size, local.buffered_min_buffering_size)
    buffering_interval = var.firehose_config.buffering_interval
    compression_format = var.firehose_config.compression_format
    kms_key_arn        = local.encryption_key.arn

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.storage_buffer.name
      log_stream_name = aws_cloudwatch_log_stream.storage_buffer.name
    }

    dynamic_partitioning_configuration {
      enabled = tostring(local.buffered_dynamic_partitioning_enabled)
    }

    # ensure our root prefixes are created
    prefix              = format("data/%s", replace(var.firehose_config.prefix, "/^data\\//", ""))
    error_output_prefix = format("errors/%s", replace(var.firehose_config.error_output_prefix, "/^errors\\//", ""))

    processing_configuration {
      enabled = tostring(var.firehose_config.metadata_extraction != null)

      dynamic "processors" {
        for_each = var.firehose_config.metadata_extraction != null ? [1] : []
        content {
          type = "MetadataExtraction"
          parameters {
            parameter_name  = "JsonParsingEngine"
            parameter_value = "JQ-1.6"
          }
          parameters {
            parameter_name  = "MetadataExtractionQuery"
            parameter_value = var.firehose_config.metadata_extraction
          }
        }
      }
    }
  }
}
