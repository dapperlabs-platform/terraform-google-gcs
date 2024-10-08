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

variable "uniform_bucket_level_access" {
  description = "Allow using object ACLs (false) or not (true, this is the recommended behavior) , defaults to true (which is the recommended practice, but not the behavior of storage API)."
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Optional map to set force destroy keyed by name, defaults to false."
  type        = bool
  default     = false
}

variable "iam" {
  description = "IAM bindings in {ROLE => [MEMBERS]} format."
  type        = map(list(string))
  default     = {}
}

variable "encryption_key" {
  description = "KMS key that will be used for encryption."
  type        = string
  default     = null
}

variable "labels" {
  description = "Labels to be attached to all buckets."
  type        = map(string)
  default     = {}
}

variable "location" {
  description = "Bucket location."
  type        = string
  default     = "EU"
}

variable "logging_config" {
  description = "Bucket logging configuration."
  type = object({
    log_bucket        = string
    log_object_prefix = string
  })
  default = null
}

variable "name" {
  description = "Bucket name suffix."
  type        = string
}

variable "prefix" {
  description = "Prefix used to generate the bucket name."
  type        = string
  default     = null
}

variable "project_id" {
  description = "Bucket project id."
  type        = string
}

variable "retention_policy" {
  description = "Bucket retention policy."
  type = object({
    retention_period = number
    is_locked        = bool
  })
  default = null
}

variable "lifecycle_rule" {
  description = "Bucket lifecycle rule."
  type = object({
    action = object({
      type          = string
      storage_class = optional(string, null)
    })
    condition = object({
      age                        = optional(number, null)
      created_before             = optional(string, null)
      with_state                 = optional(string, null)
      matches_storage_class      = optional(string, null)
      matches_prefix             = optional(string, null)
      matches_suffix             = optional(string, null)
      num_newer_versions         = optional(number, null)
      custom_time_before         = optional(string, null)
      days_since_custom_time     = optional(number, null)
      days_since_noncurrent_time = optional(number, null)
      noncurrent_time_before     = optional(string, null)
    })
  })
  default = null
}


variable "storage_class" {
  description = "Bucket storage class."
  type        = string
  default     = "MULTI_REGIONAL"
  validation {
    condition     = contains(["STANDARD", "MULTI_REGIONAL", "REGIONAL", "NEARLINE", "COLDLINE", "ARCHIVE"], var.storage_class)
    error_message = "Storage class must be one of STANDARD, MULTI_REGIONAL, REGIONAL, NEARLINE, COLDLINE, ARCHIVE."
  }
}

variable "versioning" {
  description = "Enable versioning, defaults to false."
  type        = bool
  default     = false
}

variable "cors" {
  description = "CORS configuration for the bucket. Defaults to a standard value."
  type        = any
  default = [
    {
      origin          = ["*"]
      method          = ["GET", "HEAD", "OPTIONS"]
      response_header = ["*"]
      max_age_seconds = 3600
    }
  ]
}

variable "autoclass" {
  description = "Automatically transitions objects in your bucket to appropriate storage classes based on each object's access pattern.  Defaults to false."
  type        = bool
  default     = false
}

variable "public_access_prevention" {
  description = "Prevents public access to a bucket. Acceptable values are inherited or enforced. If inherited, the bucket uses public access prevention, only if the bucket is subject to the public access prevention organization policy constraint."
  type        = string
  default     = "inherited"
}

variable "default_event_based_hold" {
  description = "Enable event based hold to new objects added to specific bucket. Defaults to false."
  type        = bool
  default     = false
}

variable "retention_duration_seconds" {
  description = "The duration in seconds that soft-deleted objects in the bucket will be retained and cannot be permanently deleted. Default value is 604800."
  type        = number
}