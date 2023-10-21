resource "aws_s3_bucket" "storage" {
  bucket = replace("${local.name_prefix}-${var.name}-${data.aws_region.current.name}-${data.aws_caller_identity.current.account_id}", "/[_.+]/", "-")
}

resource "aws_s3_bucket_versioning" "storage" {
  bucket = aws_s3_bucket.storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "storage" {
  bucket = aws_s3_bucket.storage.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = local.encryption_key.arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}
