terraform {
  required_version = "~> 1.11"

  required_providers {
    timescale = {
      source  = "timescale/timescale"
      version = "~> 2.13"
    }
  }

  # Local state, per the spec. Single-operator prototype only: this file is
  # unencrypted, unlocked, and unversioned, and it holds the service password
  # and hostname in cleartext. See README.md before sharing this directory.
  backend "local" {
    path = "terraform.tfstate"
  }
}
