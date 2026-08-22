# A submodule declares provider requirements but never a provider block or a
# backend — both belong to the root module, which passes its aws provider down
# by default inheritance.
terraform {
  required_version = "~> 1.11"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
