locals {
  s3_bucket_id = try(data.aws_s3_bucket.this[0].id, module.s3_bucket.s3_bucket_id, "")
  kms_key_arn  = try(data.aws_kms_key.this[0].arn, module.kms.key_arn, "")
  kms_key_id   = try(data.aws_kms_key.this[0].key_id, module.kms.key_id, "")
  paths_to_check = var.kv_paths

  nested_paths = [for k, v in data.vault_kv_secrets_list.kv : k if length(v.names) == 0]

  final_secrets_paths = setsubtract(local.paths_to_check, local.nested_paths)
  
  kv_secrets = flatten([for k in local.final_secrets_paths : 
                [for secret_v in nonsensitive(data.vault_kv_secrets_list.kv[k].names): "${k}/${secret_v}"]])
}

########
# Vault
########
data "vault_kv_secrets_list" "kv" {
  for_each = { for k in local.paths_to_check : k => k if var.create }
 
  path = each.key
}

data "vault_kv_secret" "secrets" {
  for_each = toset(nonsensitive(local.kv_secrets))
  
  path = each.value
}

data "archive_file" "zip" {
  for_each = toset(local.kv_secrets)

  type = "zip"

  output_path = "${path.root}/${formatdate("YY_MM_DD", plantimestamp())}/${each.key}.zip"

  dynamic "source" {
    for_each = data.vault_kv_secret.secrets

    content {
      content  = source.value.data_json
      filename = "${formatdate("YY_MM_DD", plantimestamp())}/${source.key}.json"
    }
  }
}

resource "aws_s3_object" "backup" {
  for_each = toset(local.kv_secrets)

  key        = data.archive_file.zip[each.key].output_path
  bucket     = local.s3_bucket_id
  source     = data.archive_file.zip[each.key].output_path
  kms_key_id = local.kms_key_arn

  tags = var.s3_object_tags
}

############
# S3 bucket
############
data "aws_s3_bucket" "this" {
  count = var.create && !var.create_bucket ? 1 : 0

  bucket = var.bucket_name
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.15.0"

  create_bucket = var.create && var.create_bucket

  bucket                  = var.bucket_name
  block_public_policy     = true
  block_public_acls       = true
  restrict_public_buckets = true
  ignore_public_acls      = true
  versioning = {
    enabled = var.bucket_versioning
  }

  force_destroy = var.bucket_force_destroy

  server_side_encryption_configuration = {
    rule = {
      bucket_key_enabled = true
      apply_server_side_encryption_by_default = {
        kms_master_key_id = local.kms_key_id
        sse_algorithm     = "aws:kms"
      }
    }
  }

  lifecycle_rule = [
    {
      id                                     = "incomplete_multipart_upload"
      enabled                                = true
      abort_incomplete_multipart_upload_days = 1
    },
  ]

  tags = var.tags
}

######
# KMS
######
data "aws_kms_key" "this" {
  count = var.create && !var.create_kms ? 1 : 0

  key_id = var.kms_key_id
}

module "kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "1.5.0"

  create = var.create && var.create_kms

  description             = var.kms_description
  deletion_window_in_days = var.kms_deletion_window_in_days
  enable_key_rotation     = true
  multi_region            = var.kms_multi_region

  tags = var.tags
}

resource "null_resource" "remove_zip" {
  for_each = toset([for v in local.kv_secrets : v if var.create && var.remove_zip_locally ])

  triggers = {
    archive_md5 = data.archive_file.zip[each.key].output_md5
  }

  provisioner "local-exec" {
    command = "rm -rf ${data.archive_file.zip[each.key].output_path}"
  }

  # Delete zip-archive after it is uploaded to S3 bucket
  depends_on = [
    aws_s3_object.backup
  ]
}
