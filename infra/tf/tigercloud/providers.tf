# Client credentials are issued from the TigerData console under
# Project settings -> Create credentials. They are exchanged for a
# short-lived JWT by the provider on each run.
provider "timescale" {
  project_id = var.ts_project_id
  access_key = var.ts_access_key
  secret_key = var.ts_secret_key
}
