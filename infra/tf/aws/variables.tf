variable "aws_region" {
  description = <<-EOT
    Region Terraform authenticates against. IAM is global, so this does not
    place the role anywhere; it only selects the endpoint. Defaults to
    us-west-2 to match the region the rriv-sensor-data bucket is created in by
    ../../cf/create-s3-tables-bucket.sh.
  EOT
  type        = string
  default     = "us-west-2"
  nullable    = false
}

variable "bucket_name" {
  description = <<-EOT
    S3 bucket the role is granted access to. This is the '<my_bucket>'
    placeholder in the supplied policy. Defaults to the bucket backing the
    rriv-sensor-data table.
  EOT
  type        = string
  default     = "rriv-sensor-data"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "bucket_name must be a valid S3 bucket name: 3-63 characters, lowercase letters, digits, hyphens and dots, starting and ending alphanumeric."
  }

  nullable = false
}

variable "role_name" {
  description = "Name of the IAM role granting access to the bucket."
  type        = string
  default     = "rriv-sensor-data-access"

  validation {
    condition     = can(regex("^[A-Za-z0-9+=,.@_-]{1,64}$", var.role_name))
    error_message = "role_name must be 1-64 characters from the IAM name set: alphanumerics and +=,.@_-"
  }

  nullable = false
}

variable "trusted_principal_arns" {
  description = <<-EOT
    IAM principal ARNs allowed to assume the role. Required and deliberately
    without a default: the spec does not name a trustee, and every plausible
    default is either too broad (account root trusts every principal in the
    account) or wrong. Supply the exact consumer — for the TigerLake
    integration that is the TigerData-side role ARN from the CloudFormation
    stack outputs.
  EOT
  type        = list(string)

  validation {
    condition     = length(var.trusted_principal_arns) > 0
    error_message = "trusted_principal_arns must contain at least one ARN; a role with an empty trust policy cannot be assumed by anyone."
  }

  validation {
    condition     = alltrue([for a in var.trusted_principal_arns : can(regex("^arn:aws[a-z-]*:iam::[0-9]{12}:(root|user/.+|role/.+)$", a))])
    error_message = "each entry must be an IAM principal ARN: arn:aws:iam::<account-id>:root, :user/<name>, or :role/<name>."
  }

  nullable = false
}

variable "external_id" {
  description = <<-EOT
    Optional sts:ExternalId required on assume-role. Set this whenever the
    trustee is an account you do not control — it is the documented defence
    against the confused-deputy problem. Null omits the condition.
  EOT
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to every taggable resource via provider default_tags."
  type        = map(string)
  default = {
    project   = "rriv-sensor-data"
    managedby = "terraform"
  }
  nullable = false
}
