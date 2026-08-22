terraform {
  required_version = "~> 1.11"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Local state, per the spec. Single-operator prototype only: this file is
  # unencrypted, unlocked, and unversioned. IAM role and policy documents are
  # not secret, so the exposure here is narrower than the tigercloud module's —
  # but there is still no locking and no recovery. See README.md.
  backend "local" {
    path = "terraform.tfstate"
  }
}
