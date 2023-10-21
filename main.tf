locals {
  name_prefix = "${var.product_code}-${var.qualifier}-${var.subsystem}"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
