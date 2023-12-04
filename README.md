# s3_storage

> establishes storage & complimentary resources

## general configuration

- **name** - _str_ - name of the component
- **qualifier** - _str_ - value used to distinguish one instance of this component from another in one or more aws accounts ( e.g. 'environment', branch, user, etc )
- **subsystem** - _str_ - value used to group components into subsystems of the solution
- **kms_key** - _object_ - optional reference to an existing KMS key resource/data to use for bucket encryption. ( a dedicated key will be created and used if a value is not supplied)

```hcl
# using an existing KMS key
module "your_bucket" {
  source    = "github.com/acme-widgets-org/terraform_modules_s3_storage"
  name      = "your_bucket"
  qualifier = var.qualifier
  subsystem = var.subsystem
  kms_key   = aws_kms_key.your_existing_key
}
```

## buffer configuration

you may optionally specify the s3 storage be configured with a kinesis firehose delivery stream by specifying the following properties

### firehose_config

- **buffering_size** - _number_ - buffer incoming data to the specified size, in MBs between 1 to 100, before delivering it to the destination. The default value is 5MB
- **buffering_interval** - _number_ - buffer incoming data for the specified period of time, in seconds between 60 to 900, before delivering it to the destination. The default value is 300s
- **compression_format** - _str_ - the compression format. If no value is specified, the default is GZIP. Other options include UNCOMPRESSED, ZIP, Snappy & HADOOP_SNAPPY
- **prefix** - _str_ - the s3 key prefix to use when storing file bundles - dynamic values, including those defined in `metadata_extraction` may be used here
- **error_output_prefix** - _str_ - the s3 key prefix to use when storing failed file bundles - dynamic values
- **source_kinesis_stream_arn** - _str_ - optional, specifies the source kinesis data stream feeding this buffer

```hcl
# use all defaults, no dynamic partitioning
module "your_buffered_bucket" {
  source    = "github.com/acme-widgets-org/terraform_modules_s3_storage"
  name      = "your_bucket"
  qualifier = var.qualifier
  subsystem = var.subsystem

  firehose_config = { }
}


# store messages partitioned by schemaCode attribute and date elements
module "your_buffered_bucket" {
  source    = "github.com/acme-widgets-org/terraform_modules_s3_storage"
  name      = "your_bucket"
  qualifier = var.qualifier
  subsystem = var.subsystem

  firehose_config = {
    buffering_interval = 300
    prefix              = "!{partitionKeyFromQuery:schema_code}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
    error_output_prefix = "year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/!{firehose:error-output-type}/"
    metadata_extraction = "{schema_code:.schemaCode}"
  }
}

```

## reporting configuration

your storage may be configured with athena reporting support.

- **database_name** - _str_ - the name of the glue database that your tables will be registered with
- **table_prefix** - _str_ - optional, value to prepend the table name(s) discovered by the crawler
- **table_grouping_level** - _number_ - the key segment depth to be considered an individual table. _1 is considered the root of the bucket '/'_

```hcl
# using an existing KMS key
module "your_bucket" {
  source    = "github.com/acme-widgets-org/terraform_modules_s3_storage"
  name      = "your_bucket"
  qualifier = var.qualifier
  subsystem = var.subsystem

  reporting_config = {
    database_name = "your_glue_database"
    table_prefix  = "your_prefix_"
    table_grouping_level = 2
  }
}
```
