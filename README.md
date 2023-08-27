# Terraform module for Vault KV backups to S3 bucket

Terraform module, which creates ZIP archive of Hashicorp Vault KV secrets and uploads it to S3 bucket.

[![SWUbanner](https://raw.githubusercontent.com/vshymanskyy/StandWithUkraine/main/banner2-direct.svg)](https://github.com/vshymanskyy/StandWithUkraine/blob/main/docs/README.md)

## Usage

This module leverages AWS [KMS](https://github.com/terraform-aws-modules/terraform-aws-kms) and [S3](https://github.com/terraform-aws-modules/terraform-aws-s3-bucket) terraform AWS modules for creating S3 and KMS infrastructure components.

### Default setup

S3 bucket and KMS key will be created by this module.

```hcl
module "vault_kv_backup" {
  source = "99/vault/s3-backup"

  kv_path     = "kv"
  bucket_name = "my-bucket-for-backups"
  
  tags = {
    Vault = "yes"
  }
}
```

### Using external resources

S3 bucket and KMS key are created outside of this module.

```hcl
module "vault_kv_backup" {
  source = "99/vault/s3-backup"

  kv_path = "kv"

  create_bucket = false
  bucket_name   = "my-external-bucket-for-backups"

  create_kms = false
  kms_key_id = "7037892f-7347-4efd-9d73-a91db54a8333"
}
```

## Examples

1. [Storing secrets for kv store](https://github.com/99/terraform-vault-s3-backup/tree/main/examples/complete)
1. Storing secrets for kv version2 store (WIP)

## Contributing

Report issues/questions/feature requests in the [issues](https://github.com/99/terraform-vault-s3-backup/issues/new) section.


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | >= 2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 2.0 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | >= 2.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |
| <a name="provider_null"></a> [null](#provider\_null) | >= 2.0 |
| <a name="provider_vault"></a> [vault](#provider\_vault) | >= 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_kms"></a> [kms](#module\_kms) | terraform-aws-modules/kms/aws | 1.5.0 |
| <a name="module_s3_bucket"></a> [s3\_bucket](#module\_s3\_bucket) | terraform-aws-modules/s3-bucket/aws | 3.15.0 |

## Resources

| Name | Type |
|------|------|
| [aws_s3_object.backup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [null_resource.remove_zip](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [archive_file.zip](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key) | data source |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) | data source |
| [vault_kv_secret.secrets](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/kv_secret) | data source |
| [vault_kv_secrets_list.kv](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/kv_secrets_list) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_force_destroy"></a> [bucket\_force\_destroy](#input\_bucket\_force\_destroy) | Allow deletion of non-empty bucket (can be helpful for tests) | `bool` | `false` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Name of S3 bucket for backup | `string` | `null` | no |
| <a name="input_bucket_versioning"></a> [bucket\_versioning](#input\_bucket\_versioning) | Whether to enable bucket versioning | `bool` | `false` | no |
| <a name="input_create"></a> [create](#input\_create) | Whether or not to create resources and enable backup | `bool` | `true` | no |
| <a name="input_create_bucket"></a> [create\_bucket](#input\_create\_bucket) | Whether or not to create an s3 bucket | `bool` | `true` | no |
| <a name="input_create_kms"></a> [create\_kms](#input\_create\_kms) | Whether or not to create an key management service key | `bool` | `true` | no |
| <a name="input_kms_deletion_window_in_days"></a> [kms\_deletion\_window\_in\_days](#input\_kms\_deletion\_window\_in\_days) | Deletion window of KMS key in days | `string` | `14` | no |
| <a name="input_kms_description"></a> [kms\_description](#input\_kms\_description) | Description of the KMS key | `string` | `"This key is used to encrypt objects"` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | ID of KMS key to use (specify this if it is created outside of this module) | `string` | `""` | no |
| <a name="input_kms_multi_region"></a> [kms\_multi\_region](#input\_kms\_multi\_region) | Whether to enable multi-region for KMS key | `bool` | `false` | no |
| <a name="input_kv_path"></a> [kv\_path](#input\_kv\_path) | key value secret engine mount point | `string` | `""` | no |
| <a name="input_remove_zip_locally"></a> [remove\_zip\_locally](#input\_remove\_zip\_locally) | Whether or not to remove ZIP archive locally after creation | `bool` | `true` | no |
| <a name="input_s3_object_tags"></a> [s3\_object\_tags](#input\_s3\_object\_tags) | S3 object tags (max 10 items) | `map(string)` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backup_zip"></a> [backup\_zip](#output\_backup\_zip) | Filename of zip-archive |
| <a name="output_kms_key_id"></a> [kms\_key\_id](#output\_kms\_key\_id) | ID of the generated KMS key |
| <a name="output_s3_bucket_id"></a> [s3\_bucket\_id](#output\_s3\_bucket\_id) | Name of S3 bucket |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## License

Apache 2 Licensed. See [LICENSE](https://github.com/99/terraform-vault-s3-backup/tree/main/LICENSE) for full details.

## Additional information for users from Russia and Belarus

* Russia has [illegally annexed Crimea in 2014](https://en.wikipedia.org/wiki/Annexation_of_Crimea_by_the_Russian_Federation) and [brought the war in Donbas](https://en.wikipedia.org/wiki/War_in_Donbas) followed by [full-scale invasion of Ukraine in 2022](https://en.wikipedia.org/wiki/2022_Russian_invasion_of_Ukraine).
* Russia has brought sorrow and devastations to millions of Ukrainians, killed [thousands of innocent people](https://www.ohchr.org/en/news/2023/06/ukraine-civilian-casualty-update-19-june-2023), damaged thousands of buildings including [critical infrastructure](https://www.aljazeera.com/gallery/2022/12/17/russia-launches-another-major-missile-attack-on-ukraine), caused ecocide by [blowing up a dam](https://www.reuters.com/world/europe/ukraine-security-service-says-it-intercepted-call-proving-russia-destroyed-2023-06-09/), [bombed theater](https://www.cnn.com/2022/03/16/europe/ukraine-mariupol-bombing-theater-intl/index.html) in Mariupol that had "Children" marking on the ground, [raped men and boys](https://www.theguardian.com/world/2022/may/03/men-and-boys-among-alleged-victims-by-russian-soldiers-in-ukraine), [deported children](https://www.bbc.com/news/world-europe-64992727) in the occupied territoris, and forced [millions of people](https://www.unrefugees.org/emergencies/ukraine/) to flee.
* [Putin khuylo!](https://en.wikipedia.org/wiki/Putin_khuylo!)
