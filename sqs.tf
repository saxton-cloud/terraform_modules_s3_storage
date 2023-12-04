resource "aws_sqs_queue" "crawler_work" {
  count                     = local.reporting_enabled ? 1 : 0
  name                      = "${local.name_prefix}-${var.name}-crawler-work"
  message_retention_seconds = 1209600
  # kms_master_key_id         = local.encryption_key.arn
}

resource "aws_sqs_queue_policy" "crawler_work" {
  count     = local.reporting_enabled ? 1 : 0
  queue_url = aws_sqs_queue.crawler_work[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "AccessPolicy"
    Statement = [
      # {
      #    "Effect": "Allow",
      #    "Action": [
      #       "kms:GenerateDataKey",
      #       "kms:Decrypt"
      #    ],
      #    "Resource":  "arn:aws:kms:us-east-2:123456789012:key/1234abcd-12ab-34cd-56ef-1234567890ab"
      # },
      {
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.crawler_work[0].arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.s3_notifications.arn
          }
        }
      }
    ]
  })
}
