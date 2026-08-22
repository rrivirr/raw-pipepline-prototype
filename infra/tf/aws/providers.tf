# Credentials are taken from the ambient AWS credential chain (environment,
# shared config/credentials file, SSO cache, or instance role). Nothing
# authenticating is declared here, so no secret enters state or a .tfvars file.
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.tags
  }
}
