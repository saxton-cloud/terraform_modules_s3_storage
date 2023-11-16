variable "qualifier" {
  description = "value used to distinguish one instance of the component from another within one or more accounts ( 'environment', branch, etc )"
  type        = string
}

variable "product_code" {
  description = "value used to group components and subsystems into a singe solution"
  type        = string
  default     = "acme"
}

variable "subsystem" {
  description = "value used to group components into subsystems of the solution"
  type        = string
}

variable "name" {
  description = "name of the storage resources"
  type        = string
}

variable "kms_key" {
  description = "kms key ( resource or data ) used to encrypt"
  default     = null
}

variable "firehose_config" {
  description = "optional, used to specify the firehose buffer configuration"
  type = object({
    source_kinesis_stream_arn = optional(string, null)
    buffering_size            = optional(number, 5)
    buffering_interval        = optional(number, 300)
    compression_format        = optional(string, "GZIP")
    prefix                    = optional(string, "data/")
    error_output_prefix       = optional(string, "errors/")
    metadata_extraction       = optional(string, null)
  })
  default = null
}
