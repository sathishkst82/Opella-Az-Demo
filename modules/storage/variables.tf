variable "resource_group_name" {
  description = "Resource group name for storage resources."
  type        = string
}

variable "location" {
  description = "Azure region for storage resources."
  type        = string
}

variable "storage_account_name" {
  description = "Globally unique storage account name."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Storage account name must be 3-24 lowercase letters and numbers."
  }
}

variable "account_replication_type" {
  description = "Replication type."
  type        = string
  default     = "ZRS"

  validation {
    condition     = contains(["LRS", "ZRS", "GRS", "RAGRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "Replication type must be a valid Azure Storage replication option."
  }
}

variable "containers" {
  description = "Blob containers keyed by logical name."
  type = map(object({
    name                  = string
    container_access_type = optional(string, "private")
  }))
  default = {}
}

variable "network_rules" {
  description = "Storage firewall configuration."
  type = object({
    default_action             = optional(string, "Deny")
    bypass                     = optional(list(string), ["AzureServices"])
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default = {}
}

variable "private_endpoint" {
  description = "Optional blob private endpoint configuration."
  type = object({
    enabled             = optional(bool, false)
    subnet_id           = optional(string)
    private_dns_zone_id = optional(string)
  })
  default = {}
}

variable "lifecycle_rules" {
  description = "Storage lifecycle management rules."
  type = map(object({
    enabled      = optional(bool, true)
    prefix_match = optional(list(string), [])
    blob_types   = optional(list(string), ["blockBlob"])
    base_blob = optional(object({
      tier_to_cool_after_days_since_modification_greater_than    = optional(number)
      tier_to_archive_after_days_since_modification_greater_than = optional(number)
      delete_after_days_since_modification_greater_than          = optional(number)
    }), {})
  }))
  default = {}
}

variable "tags" {
  description = "Tags applied to all storage resources."
  type        = map(string)
  default     = {}
}
