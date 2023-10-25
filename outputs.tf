output "kms_key_id" {
  description = "ID of the generated KMS key"
  value       = module.kms.key_id
}

output "s3_bucket_id" {
  description = "Name of S3 bucket"
  value       = local.s3_bucket_id
}

output "backup_zip" {
  description = "Filenames of zip-archive"
  value       = try(data.archive_file.zip[*].output_path, null)
}
