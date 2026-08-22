variable "role_name" {
  description = "Name of the IAM role. Also used to name the managed policy."
  type        = string
  nullable    = false
}

variable "bucket_name" {
  description = "S3 bucket the policy grants access to; the '<my_bucket>' placeholder in the supplied policy."
  type        = string
  nullable    = false
}

variable "trusted_principal_arns" {
  description = "IAM principal ARNs allowed to assume the role. Must be non-empty."
  type        = list(string)

  validation {
    condition     = length(var.trusted_principal_arns) > 0
    error_message = "trusted_principal_arns must contain at least one ARN."
  }

  nullable = false
}

variable "external_id" {
  description = "Optional sts:ExternalId required on assume-role. Null omits the condition."
  type        = string
  default     = null
}
