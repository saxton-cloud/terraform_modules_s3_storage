locals {
  encryption_key = var.kms_key != null ? var.kms_key : aws_kms_key.encryption[0]
}

resource "aws_kms_key" "encryption" {
  count                   = var.kms_key == null ? 1 : 0
  description             = "dedicated key used by '${local.name_prefix}-${var.name}' elements"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "CommonPolicy"
    Statement = [
      {
        Sid    = "AccountRootFullAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${local.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "S3NotificationAccess"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = [
          "kms:GenerateDataKey",
          "kms:Decrypt",
          "kms:Encrypt"
        ]
        Resource = "*"
      }
    ]
  })
}
resource "aws_kms_alias" "encryption" {
  count         = var.kms_key == null ? 1 : 0
  name          = "alias/${var.product_code}/${var.qualifier}/${var.subsystem}/${var.name}"
  target_key_id = aws_kms_key.encryption[0].key_id
}
