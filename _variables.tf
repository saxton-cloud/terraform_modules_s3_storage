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

variable "kms_key_id" {
  description = "kms key id or alias to use for encryption - will create and use dedicated key not specified"
  type        = string
  default     = null
}
