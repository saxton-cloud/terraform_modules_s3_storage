locals {
  name_prefix       = "${var.product_code}-${var.qualifier}-${var.subsystem}"
  buffered          = var.firehose_config != null
  reporting_enabled = var.reporting_config != null
  account_id        = data.aws_caller_identity.current.account_id
  region            = data.aws_region.current.name
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
