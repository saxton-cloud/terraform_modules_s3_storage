resource "aws_glue_crawler" "storage" {
  count         = local.reporting_enabled ? 1 : 0
  database_name = var.reporting_config.database_name
  name          = "${local.name_prefix}-${var.name}"
  role          = aws_iam_role.storage_crawler[0].arn
  table_prefix  = var.reporting_config.table_prefix
  schedule      = "cron(0/5 * * * ? *)"

  # https://docs.aws.amazon.com/glue/latest/dg/crawler-configuration.html#crawler-grouping-policy
  configuration = jsonencode(
    {
      Grouping = {
        TableGroupingPolicy     = "CombineCompatibleSchemas"
        TableLevelConfiguration = var.reporting_config.table_grouping_level
      }
      CrawlerOutput = {
        Partitions = { AddOrUpdateBehavior = "InheritFromTable" }
      }
      Version = 1
    }
  )
  recrawl_policy {
    recrawl_behavior = "CRAWL_EVENT_MODE"
  }
  s3_target {
    path            = "s3://${aws_s3_bucket.storage.bucket}"
    event_queue_arn = aws_sqs_queue.crawler_work[0].arn
  }
}
