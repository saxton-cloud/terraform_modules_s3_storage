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
      Bucket = "$bucket"
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "errors_4xx" {
  alarm_name                = "${local.name_prefix}-${var.name}-4xx-errors-encountered"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "4xxErrors"
  namespace                 = "AWS/S3"
  period                    = 60
  statistic                 = "Sum"
  threshold                 = 1
  alarm_description         = "4xx Errors encountered"
  insufficient_data_actions = []
}
resource "aws_cloudwatch_metric_alarm" "errors_5xx" {
  alarm_name                = "${local.name_prefix}-${var.name}-5xx-errors-encountered"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "5xxErrors"
  namespace                 = "AWS/S3"
  period                    = 60
  statistic                 = "Sum"
  threshold                 = 1
  alarm_description         = "4xx Errors encountered"
  insufficient_data_actions = []
}


resource "aws_cloudwatch_metric_alarm" "buffer_approaching_incoming_bytes_threshold" {
  count                     = length(aws_kinesis_firehose_delivery_stream.storage_buffer)
  alarm_name                = "${local.name_prefix}-${var.name}-buffer-incoming-bytes-approaching-threshold"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 1
  threshold                 = 80
  alarm_description         = "Storage Firehose IncomingBytes approaching maximum threshold"
  insufficient_data_actions = []

  metric_query {
    id          = "e1"
    expression  = "100 * (e2/m2)"
    label       = "PercentageOfMaxIncomingBytes"
    return_data = "true"
  }

  metric_query {
    id         = "e2"
    expression = "m1/300"
    label      = "IncomingBytesPerSecond"
  }

  metric_query {
    id = "m1"
    metric {
      metric_name = "IncomingBytes"
      namespace   = "AWS/Firehose"
      period      = 300
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        DeliveryStreamName = aws_kinesis_firehose_delivery_stream.storage_buffer[0].name
      }
    }
  }

  metric_query {
    id = "m2"
    metric {
      metric_name = "BytesPerSecondLimit"
      namespace   = "AWS/Firehose"
      period      = 300
      stat        = "Maximum"

      dimensions = {
        DeliveryStreamName = aws_kinesis_firehose_delivery_stream.storage_buffer[0].name
      }
    }
  }
}
resource "aws_cloudwatch_metric_alarm" "buffer_approaching_incoming_records_threshold" {
  count                     = length(aws_kinesis_firehose_delivery_stream.storage_buffer)
  alarm_name                = "${local.name_prefix}-${var.name}-buffer-incoming-records-approaching-threshold"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 1
  threshold                 = 80
  alarm_description         = "Storage Firehose IncomingRecords approaching maximum threshold"
  insufficient_data_actions = []

  metric_query {
    id          = "e1"
    expression  = "100 * (e2/m2)"
    label       = "PercentageOfMaxIncomingRecords"
    return_data = "true"
  }

  metric_query {
    id         = "e2"
    expression = "m1/300"
    label      = "IncomingRecordsPerSecond"
  }

  metric_query {
    id = "m1"
    metric {
      metric_name = "IncomingRecords"
      namespace   = "AWS/Firehose"
      period      = 300
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        DeliveryStreamName = aws_kinesis_firehose_delivery_stream.storage_buffer[0].name
      }
    }
  }

  metric_query {
    id = "m2"
    metric {
      metric_name = "RecordsPerSecondLimit"
      namespace   = "AWS/Firehose"
      period      = 300
      stat        = "Maximum"

      dimensions = {
        DeliveryStreamName = aws_kinesis_firehose_delivery_stream.storage_buffer[0].name
      }
    }
  }
}
resource "aws_cloudwatch_metric_alarm" "buffer_approaching_incoming_put_requests_threshold" {
  count                     = length(aws_kinesis_firehose_delivery_stream.storage_buffer)
  alarm_name                = "${local.name_prefix}-${var.name}-buffer-put-requests-approaching-threshold"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 1
  threshold                 = 80
  alarm_description         = "Storage Firehose Incoming Put Requests approaching maximum threshold"
  insufficient_data_actions = []

  metric_query {
    id          = "e1"
    expression  = "100 * (e2/m2)"
    label       = "PercentageOfMaxIncomingPutRequests"
    return_data = "true"
  }

  metric_query {
    id         = "e2"
    expression = "m1/300"
    label      = "IncomingPutRequestsPerSecond"
  }

  metric_query {
    id = "m1"
    metric {
      metric_name = "IncomingPutRequests"
      namespace   = "AWS/Firehose"
      period      = 300
      stat        = "Sum"
      unit        = "Count"

      dimensions = {
        DeliveryStreamName = aws_kinesis_firehose_delivery_stream.storage_buffer[0].name
      }
    }
  }

  metric_query {
    id = "m2"
    metric {
      metric_name = "PutRequestsPerSecondLimit"
      namespace   = "AWS/Firehose"
      period      = 300
      stat        = "Maximum"

      dimensions = {
        DeliveryStreamName = aws_kinesis_firehose_delivery_stream.storage_buffer[0].name
      }
    }
  }
}
resource "aws_cloudwatch_metric_alarm" "buffer_approaching_active_partition_threshold" {
  count                     = length(aws_kinesis_firehose_delivery_stream.storage_buffer)
  alarm_name                = "${local.name_prefix}-${var.name}-buffer-partition-count-approaching-threshold"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 1
  threshold                 = 80
  alarm_description         = "Storage Firehose Active Partitions are approaching maximum threshold"
  insufficient_data_actions = []

  metric_query {
    id          = "e1"
    expression  = "100 * (m1/m2)"
    label       = "PercentageOfMaxPartitionsLimit"
    return_data = "true"
  }

  metric_query {
    id = "m1"
    metric {
      metric_name = "PartitionCount"
      namespace   = "AWS/Firehose"
      period      = 60
      stat        = "Maximum"
      unit        = "Count"

      dimensions = {
        DeliveryStreamName = aws_kinesis_firehose_delivery_stream.storage_buffer[0].name
      }
    }
  }

  metric_query {
    id = "m2"
    metric {
      metric_name = "ActivePartitionsLimit"
      namespace   = "AWS/Firehose"
      period      = 60
      stat        = "Maximum"

      dimensions = {
        DeliveryStreamName = aws_kinesis_firehose_delivery_stream.storage_buffer[0].name
      }
    }
  }
}
