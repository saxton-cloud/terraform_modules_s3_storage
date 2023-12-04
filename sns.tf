resource "aws_sns_topic" "s3_notifications" {
  name              = replace("${local.name_prefix}-${var.name}-notifications", "/[_.+]/", "-")
  kms_master_key_id = local.encryption_key.arn
}

resource "aws_sns_topic_policy" "s3_notifications" {
  arn = aws_sns_topic.s3_notifications.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "BucketPublishOnly"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = [
          "SNS:Publish"
        ]
        Resource = aws_sns_topic.s3_notifications.arn
        Condition = {
          ArnLike = {
            "aws:SourceArn" = aws_s3_bucket.storage.arn
          }
          StringEquals = {
            "aws:SourceAccount" = local.account_id
          }
        }
      },
      {
        Sid    = "AccountSubscribeOnly"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action = [
          "SNS:GetTopicAttributes",
          "SNS:Subscribe",
          "SNS:ListSubscriptionsByTopic"
        ]
        Resource = aws_sns_topic.s3_notifications.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = local.account_id
          }
        }
      }
    ]
  })
}

resource "aws_sns_topic_subscription" "crawler_work_queue" {
  count     = local.reporting_enabled ? 1 : 0
  topic_arn = aws_sns_topic.s3_notifications.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.crawler_work[0].arn
}
