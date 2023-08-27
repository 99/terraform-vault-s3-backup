output "kms_key_id" {
  description = "ID of the generated KMS key"
  value       = module.vault_kv_backup.kms_key_id
}

output "s3_bucket_id" {
  description = "Name of S3 bucket"
  value       = module.vault_kv_backup.s3_bucket_id
}

output "backup_zip" {
  description = "Filename of zip-archive"
  value       = module.vault_kv_backup.backup_zip
}
