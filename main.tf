locals {
  name_prefix = "${var.product_code}-${var.qualifier}-${var.subsystem}"
  buffered    = var.firehose_config != null
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
