/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  prefix = (
    var.prefix == null || var.prefix == "" # keep "" for backward compatibility
    ? ""
    : join("-", [var.prefix, lower(var.location), ""])
  )
  iam_roles = merge([
    for role_name, members in var.iam : {
      for member in members :
      "${role_name}-${member}" => {
        role_name = role_name
        member    = member
      }
    }
  ]...)
}

resource "google_storage_bucket" "bucket" {
  name                        = "${local.prefix}${lower(var.name)}"
  project                     = var.project_id
  location                    = var.location
  storage_class               = var.storage_class
  public_access_prevention    = var.public_access_prevention
  force_destroy               = var.force_destroy
  uniform_bucket_level_access = var.uniform_bucket_level_access
  default_event_based_hold    = var.default_event_based_hold

  versioning {
    enabled = var.versioning
  }
  labels = merge(var.labels, {
    location      = lower(var.location)
    storage_class = lower(var.storage_class)
  })

  dynamic "autoclass" {
    for_each = var.autoclass == false ? [] : [""]
    content {
      enabled = var.autoclass
    }
  }

  dynamic "encryption" {
    for_each = var.encryption_key == null ? [] : [""]

    content {
      default_kms_key_name = var.encryption_key
    }
  }

  dynamic "retention_policy" {
    for_each = var.retention_policy == null ? [] : [""]
    content {
      retention_period = var.retention_policy.retention_period
      is_locked        = var.retention_policy.is_locked
    }
  }

  dynamic "logging" {
    for_each = var.logging_config == null ? [] : [""]
    content {
      log_bucket        = var.logging_config.log_bucket
      log_object_prefix = var.logging_config.log_object_prefix
    }
  }

  dynamic "cors" {
    for_each = var.cors
    content {
      origin          = lookup(cors.value, "origin", null)
      method          = lookup(cors.value, "method", null)
      response_header = lookup(cors.value, "response_header", null)
      max_age_seconds = lookup(cors.value, "max_age_seconds", null)
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rule == null ? [] : [""]
    content {
      action {
        type          = var.lifecycle_rule.action.type          // type - The type of the action of this Lifecycle Rule. Supported values: Delete and SetStorageClass.
        storage_class = var.lifecycle_rule.action.storage_class // storage_class - (Required if action type is SetStorageClass) The target Storage Class of objects affected by this Lifecycle Rule. "NEARLINE", "COLDLINE", "ARCHIVE", or "STANDARD"
      }
      condition {
        age                        = var.lifecycle_rule.condition.age                        // age - (Optional) Minimum age of an object in days to satisfy this condition.
        created_before             = var.lifecycle_rule.condition.created_before             // created_before - (Optional) Creation date of an object in RFC 3339 (e.g. 2017-06-13) to satisfy this condition.
        with_state                 = var.lifecycle_rule.condition.with_state                 // with_state - (Optional) Match to live and/or archived objects. Supported values include: "LIVE", "ARCHIVED", "ANY".
        matches_storage_class      = var.lifecycle_rule.condition.matches_storage_class      // matches_storage_class - (Optional) Comma delimited string for storage class of objects to satisfy this condition. Supported values include: MULTI_REGIONAL, REGIONAL, NEARLINE, COLDLINE, STANDARD, DURABLE_REDUCED_AVAILABILITY.
        matches_prefix             = var.lifecycle_rule.condition.matches_prefix             // matches_prefix - (Optional) One or more matching name prefixes to satisfy this condition.
        matches_suffix             = var.lifecycle_rule.condition.matches_suffix             // matches_suffix - (Optional) One or more matching name suffixes to satisfy this condition.
        num_newer_versions         = var.lifecycle_rule.condition.num_newer_versions         // num_newer_versions - (Optional) Relevant only for versioned objects. The number of newer versions of an object to satisfy this condition.
        custom_time_before         = var.lifecycle_rule.condition.custom_time_before         // custom_time_before - (Optional) A date in the RFC 3339 format YYYY-MM-DD. This condition is satisfied when the customTime metadata for the object is set to an earlier date than the date used in this lifecycle condition.
        days_since_custom_time     = var.lifecycle_rule.condition.days_since_custom_time     // days_since_custom_time - (Optional) The number of days from the Custom-Time metadata attribute after which this condition becomes true.
        days_since_noncurrent_time = var.lifecycle_rule.condition.days_since_noncurrent_time // days_since_noncurrent_time - (Optional) Relevant only for versioned objects. Number of days elapsed since the noncurrent timestamp of an object.
        noncurrent_time_before     = var.lifecycle_rule.condition.noncurrent_time_before     // noncurrent_time_before - (Optional) Relevant only for versioned objects. The date in RFC 3339 (e.g. 2017-06-13) when the object became nonconcurrent.
      }
    }
  }

  dynamic "soft_delete_policy" {
    for_each = var.retention_duration_seconds == null ? [] : [""]
    content {
      retention_duration_seconds = var.retention_duration_seconds
    }
  }
}

resource "google_storage_bucket_iam_member" "members" {
  for_each = local.iam_roles
  bucket   = google_storage_bucket.bucket.name
  role     = each.value.role_name
  member   = each.value.member
}
