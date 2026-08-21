variable "ts_project_id" {
  description = "TigerData project ID that owns the service."
  type        = string
  nullable    = false
}

variable "ts_access_key" {
  description = "TigerData client credential public key."
  type        = string
  nullable    = false
}

variable "ts_secret_key" {
  description = "TigerData client credential secret key."
  type        = string
  nullable    = false
  sensitive   = true
}

variable "service_name" {
  description = "Name assigned to the TimescaleDB service."
  type        = string
  default     = "sensor-ingest"

  validation {
    condition     = length(var.service_name) > 0 && length(var.service_name) <= 63
    error_message = "service_name must be between 1 and 63 characters."
  }

  nullable = false
}

variable "region_code" {
  description = <<-EOT
    Region the service is provisioned in. The spec does not name a region, so
    this defaults to us-east-1. AWS naming is used as-is; Azure regions carry an
    "az-" prefix (for example az-eastus2).
  EOT
  type        = string
  default     = "us-east-1"
  nullable    = false
}

variable "milli_cpu" {
  description = "Compute allocation in milli-CPU. 500 = 0.5 CPU."
  type        = number
  default     = 500

  validation {
    condition     = contains([500, 1000, 2000, 4000, 8000, 16000, 32000], var.milli_cpu)
    error_message = "milli_cpu must be one of 500, 1000, 2000, 4000, 8000, 16000, 32000."
  }

  nullable = false
}

variable "memory_gb" {
  description = "Memory allocation in GiB. Must match the milli_cpu tier."
  type        = number
  default     = 2

  validation {
    condition = var.memory_gb == lookup({
      "500"   = 2
      "1000"  = 4
      "2000"  = 8
      "4000"  = 16
      "8000"  = 32
      "16000" = 64
      "32000" = 128
    }, tostring(var.milli_cpu), -1)
    error_message = "memory_gb must match the milli_cpu tier: 500/2, 1000/4, 2000/8, 4000/16, 8000/32, 16000/64, 32000/128."
  }

  nullable = false
}
