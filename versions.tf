terraform {
  required_version = ">= 1.5"

  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">= 3.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 2.0"
    }
  }
}
