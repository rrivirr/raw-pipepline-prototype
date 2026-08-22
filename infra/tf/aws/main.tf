# The IAM role is a submodule so the role/policy pair can be instantiated more
# than once — a second bucket, or separate reader and writer roles — without
# duplicating the policy document.
module "iam" {
  source = "./iam"

  role_name              = var.role_name
  bucket_name            = var.bucket_name
  trusted_principal_arns = var.trusted_principal_arns
  external_id            = var.external_id
}
