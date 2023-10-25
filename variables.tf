variable "create" {
  description = "Whether or not to create resources and enable backup"
  type        = bool
  default     = true
}

variable "create_bucket" {
  description = "Whether or not to create an s3 bucket"
  type        = bool
  default     = true
}

variable "create_kms" {
  description = "Whether or not to create an key management service key"
  type        = bool
  default     = true
}

variable "remove_zip_locally" {
  description = "Whether or not to remove ZIP archive locally after creation"
  type        = bool
  default     = true
}

# Tags
variable "s3_object_tags" {
  description = "S3 object tags (max 10 items)"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags"
  type        = map(string)
  default     = {}
}

# Vault
variable "kv_paths" {
  description = "List of keys value secret engines"
  type        = list(string)
  default     = []
}

# S3 bucket
variable "bucket_name" {
  description = "Name of S3 bucket for backup"
  type        = string
  default     = null
}

variable "bucket_force_destroy" {
  description = "Allow deletion of non-empty bucket (can be helpful for tests)"
  type        = bool
  default     = false
}

variable "bucket_versioning" {
  description = "Whether to enable bucket versioning"
  type        = bool
  default     = false
}

# KMS
variable "kms_key_id" {
  description = "ID of KMS key to use (specify this if it is created outside of this module)"
  type        = string
  default     = ""
}

variable "kms_multi_region" {
  description = "Whether to enable multi-region for KMS key"
  type        = bool
  default     = false
}

variable "kms_description" {
  description = "Description of the KMS key"
  type        = string
  default     = "This key is used to encrypt objects"
}

variable "kms_deletion_window_in_days" {
  description = "Deletion window of KMS key in days"
  type        = string
  default     = 14
}
