# Google Cloud Storage Module

## TODO

- [ ] add support for defining [notifications](https://www.terraform.io/docs/providers/google/r/storage_notification.html)

## Example

```hcl
module "bucket" {
  source     = "github.com/dapperlabs-platform/terraform-google-gcs?ref=tag"
  project_id = "myproject"
  prefix     = "test"
  name       = "my-bucket"
  iam = {
    "roles/storage.admin" = ["group:storage@example.com"]
  }
}
# tftest:modules=1:resources=2
```

### Example with Cloud KMS

```hcl
module "bucket" {
  source     = "../modules/gcs"
  project_id = "myproject"
  prefix     = "test"
  name       = "my-bucket"
  iam = {
    "roles/storage.admin" = ["group:storage@example.com"]
  }
  encryption_key = "my-encryption-key"
}
# tftest:modules=1:resources=2
```

### Example with retention policy

```hcl
module "bucket" {
  source     = "../modules/gcs"
  project_id = "myproject"
  prefix     = "test"
  name       = "my-bucket"
  iam = {
    "roles/storage.admin" = ["group:storage@example.com"]
  }

  retention_policy = {
    retention_period = 100
    is_locked        = true
  }

  logging_config = {
    log_bucket        = var.bucket
    log_object_prefix = null
  }
}
# tftest:modules=1:resources=2
```

<!-- BEGIN_TF_DOCS -->
Copyright 2021 Google LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.8 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.55 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.55 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_storage_bucket.bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_member.members](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_autoclass"></a> [autoclass](#input\_autoclass) | Automatically transitions objects in your bucket to appropriate storage classes based on each object's access pattern.  Defaults to false. | `bool` | `false` | no |
| <a name="input_cors"></a> [cors](#input\_cors) | CORS configuration for the bucket. Defaults to a standard value. | `any` | <pre>[<br>  {<br>    "max_age_seconds": 3600,<br>    "method": [<br>      "GET",<br>      "HEAD",<br>      "OPTIONS"<br>    ],<br>    "origin": [<br>      "*"<br>    ],<br>    "response_header": [<br>      "*"<br>    ]<br>  }<br>]</pre> | no |
| <a name="input_default_event_based_hold"></a> [default\_event\_based\_hold](#input\_default\_event\_based\_hold) | Enable event based hold to new objects added to specific bucket. Defaults to false. | `bool` | `false` | no |
| <a name="input_encryption_key"></a> [encryption\_key](#input\_encryption\_key) | KMS key that will be used for encryption. | `string` | `null` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Optional map to set force destroy keyed by name, defaults to false. | `bool` | `false` | no |
| <a name="input_iam"></a> [iam](#input\_iam) | IAM bindings in {ROLE => [MEMBERS]} format. | `map(list(string))` | `{}` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels to be attached to all buckets. | `map(string)` | `{}` | no |
| <a name="input_lifecycle_rule"></a> [lifecycle\_rule](#input\_lifecycle\_rule) | Bucket lifecycle rule. | <pre>object({<br>    action = object({<br>      type          = string<br>      storage_class = optional(string, null)<br>    })<br>    condition = object({<br>      age                        = optional(number, null)<br>      created_before             = optional(string, null)<br>      with_state                 = optional(string, null)<br>      matches_storage_class      = optional(string, null)<br>      matches_prefix             = optional(string, null)<br>      matches_suffix             = optional(string, null)<br>      num_newer_versions         = optional(number, null)<br>      custom_time_before         = optional(string, null)<br>      days_since_custom_time     = optional(number, null)<br>      days_since_noncurrent_time = optional(number, null)<br>      noncurrent_time_before     = optional(string, null)<br>    })<br>  })</pre> | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Bucket location. | `string` | `"EU"` | no |
| <a name="input_logging_config"></a> [logging\_config](#input\_logging\_config) | Bucket logging configuration. | <pre>object({<br>    log_bucket        = string<br>    log_object_prefix = string<br>  })</pre> | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Bucket name suffix. | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix used to generate the bucket name. | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Bucket project id. | `string` | n/a | yes |
| <a name="input_public_access_prevention"></a> [public\_access\_prevention](#input\_public\_access\_prevention) | Prevents public access to a bucket. Acceptable values are inherited or enforced. If inherited, the bucket uses public access prevention, only if the bucket is subject to the public access prevention organization policy constraint. | `string` | `"inherited"` | no |
| <a name="input_retention_duration_seconds"></a> [retention\_duration\_seconds](#input\_retention\_duration\_seconds) | The duration in seconds that soft-deleted objects in the bucket will be retained and cannot be permanently deleted. Default value is 604800. | `number` | n/a | yes |
| <a name="input_retention_policy"></a> [retention\_policy](#input\_retention\_policy) | Bucket retention policy. | <pre>object({<br>    retention_period = number<br>    is_locked        = bool<br>  })</pre> | `null` | no |
| <a name="input_storage_class"></a> [storage\_class](#input\_storage\_class) | Bucket storage class. | `string` | `"MULTI_REGIONAL"` | no |
| <a name="input_uniform_bucket_level_access"></a> [uniform\_bucket\_level\_access](#input\_uniform\_bucket\_level\_access) | Allow using object ACLs (false) or not (true, this is the recommended behavior) , defaults to true (which is the recommended practice, but not the behavior of storage API). | `bool` | `true` | no |
| <a name="input_versioning"></a> [versioning](#input\_versioning) | Enable versioning, defaults to false. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket"></a> [bucket](#output\_bucket) | Bucket resource. |
| <a name="output_name"></a> [name](#output\_name) | Bucket name. |
| <a name="output_url"></a> [url](#output\_url) | Bucket URL. |
<!-- END_TF_DOCS -->