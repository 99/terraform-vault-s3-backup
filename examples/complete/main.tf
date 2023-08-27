locals {
  kv_path = "kv"
}

provider "vault" {
  address = var.vault_url
}

provider "aws" {
  region = "us-west-2"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_region_validation      = true

  default_tags {
    tags = {
      Name       = "ex-${basename(path.cwd)}"
      Example    = "complete"
      Repository = "github.com/99/terraform-vault-s3-backup"
    }
  }
}

###############################################
# S3 bucket and KMS key created by this module
###############################################
module "vault_kv_backup" {
  source = "../../"

  kv_path     = local.kv_path
  bucket_name = random_pet.this.id

  # Allow deletion of non-empty bucket (can be helpful for tests)
  bucket_force_destroy = true
}

#######################################################
# S3 bucket and KMS key created outside of this module
#######################################################
module "vault_kv_backup_external" {
  source = "../../"

  kv_path = local.kv_path

  create_bucket = false
  bucket_name   = module.s3_bucket.s3_bucket_id

  create_kms = false
  kms_key_id = module.kms.key_id

  # Allow deletion of non-empty bucket (can be helpful for tests)
  bucket_force_destroy = true
}

###########
# Disabled
###########
module "disabled" {
  source = "../../"

  create = false
}

#######################
# Additional resources
#######################
resource "random_pet" "this" {
  length = 2
}

#####################
# External resources
#####################
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket        = "${random_pet.this.id}-vault-backups"
  force_destroy = true
}

module "kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 1.0"
}

##################
# Vault bootstrap
##################
resource "vault_policy" "vault_kv_backup_executor" {
  name   = "vault_kv_backup_executor"
  policy = <<EOT
path "${local.kv_path}/*" {
  capabilities = ["read", "list", "create"]
}

path "auth/token/create" {
  capabilities = ["create", "read", "update", "list"]
}
EOT
}

resource "vault_mount" "kv" {
  path = local.kv_path
  type = "kv"
}

resource "vault_auth_backend" "vault_kv_backup_executor" {
  type = "approle"
  path = "vault_kv_backup_executor"
}

resource "vault_approle_auth_backend_role" "vault_kv_backup_executor" {
  backend        = vault_auth_backend.vault_kv_backup_executor.path
  role_name      = "vault_kv_backup_executor"
  token_policies = ["vault_kv_backup_executor"]
}

resource "vault_approle_auth_backend_role_secret_id" "id" {
  backend   = vault_auth_backend.vault_kv_backup_executor.path
  role_name = vault_approle_auth_backend_role.vault_kv_backup_executor.role_name
}

resource "vault_approle_auth_backend_login" "login" {
  backend   = vault_auth_backend.vault_kv_backup_executor.path
  role_id   = vault_approle_auth_backend_role.vault_kv_backup_executor.role_id
  secret_id = vault_approle_auth_backend_role_secret_id.id.secret_id
}

resource "vault_kv_secret" "example" {
  count     = 5
  data_json = jsonencode({ "foo${count.index}" : "bar.${count.index}" })
  path      = "${local.kv_path}/example_${count.index}"

  depends_on = [
    vault_policy.vault_kv_backup_executor,
    vault_approle_auth_backend_login.login,
    vault_mount.kv
  ]
}
