locals {
  policy_name_prefix = replace(title(replace("${var.product_code}-${var.qualifier}-${var.subsystem}-${var.name}", "/[_-]/", " ")), " ", "")
  policy_path        = "/${var.product_code}/${var.qualifier}/"
}

resource "aws_iam_role" "storage_buffer" {
  count = local.buffered ? 1 : 0
  name  = "${local.name_prefix}-${var.name}-firehose-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = {
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "firehose.amazonaws.com"
      }
    }
  })
}

resource "aws_iam_role_policy" "buffer_storage_access" {
  count = local.buffered ? 1 : 0
  name  = "buffer_storage_access"
  role  = aws_iam_role.storage_buffer[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ]
        Resource = [
          aws_s3_bucket.storage.arn,
          "${aws_s3_bucket.storage.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = [
          local.encryption_key.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:PutLogEvents"
        ]
        Resource = [
          aws_cloudwatch_log_stream.storage_buffer.arn
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "policy" {
  count       = try(var.firehose_config.source_kinesis_stream_arn, null) != null ? 1 : 0
  name        = "${local.policy_name_prefix}KinesisSourceStreamAccess"
  path        = local.policy_path
  description = "Grants access to source kinesis data stream"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kinesis:DescribeStream",
          "kinesis:GetShardIterator",
          "kinesis:GetRecords",
          "kinesis:ListShards"
        ]
        Effect   = "Allow"
        Resource = var.firehose_config.source_kinesis_stream_arn
      },
    ]
  })
}


resource "aws_iam_role" "storage_crawler" {
  count = local.reporting_enabled ? 1 : 0
  name  = "${local.name_prefix}-${var.name}-crawler-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = {
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "glue.amazonaws.com"
      }
    }
  })
}

resource "aws_iam_role_policy" "storage_crawler_access" {
  count = local.reporting_enabled ? 1 : 0
  name  = "crawler_access"
  role  = aws_iam_role.storage_crawler[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DataSourceAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          aws_s3_bucket.storage.arn,
          "${aws_s3_bucket.storage.arn}/*"
        ]
      },
      {
        Sid    = "DataSourceEncryptionAccess"
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = [
          local.encryption_key.arn
        ]
      },
      {
        Sid    = "WorkQueueAccess"
        Effect = "Allow"
        Action = [
          "sqs:DeleteMessage",
          "sqs:GetQueueUrl",
          "sqs:ListDeadLetterSourceQueues",
          "sqs:ReceiveMessage",
          "sqs:GetQueueAttributes",
          "sqs:ListQueueTags",
          "sqs:SetQueueAttributes",
          "sqs:PurgeQueue"
        ]
        Resource = aws_sqs_queue.crawler_work[0].arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "aws_glue_service_role" {
  count      = local.reporting_enabled ? 1 : 0
  role       = aws_iam_role.storage_crawler[0].name
  policy_arn = data.aws_iam_policy.aws_glue_service_role.arn
}

data "aws_iam_policy" "aws_glue_service_role" {
  name = "AWSGlueServiceRole"
}
