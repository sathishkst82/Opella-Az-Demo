variable "resource_group_name" {
  description = "Resource group name for compute resources."
  type        = string
}

variable "location" {
  description = "Azure region for compute resources."
  type        = string
}

variable "vms" {
  description = "Windows VMs keyed by logical instance name."
  type = map(object({
    name                          = string
    computer_name                 = optional(string)
    size                          = string
    subnet_id                     = string
    admin_username                = string
    admin_password                = string
    private_ip_address_allocation = optional(string, "Dynamic")
    private_ip_address            = optional(string)
    enable_public_ip              = optional(bool, false)
    zone                          = optional(string)
    source_image_reference = optional(object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
      }), {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2022-datacenter-azure-edition"
      version   = "latest"
    })
    os_disk = optional(object({
      caching              = optional(string, "ReadWrite")
      storage_account_type = optional(string, "Premium_LRS")
      disk_size_gb         = optional(number, 64)
    }), {})
    data_disks = optional(map(object({
      lun                  = number
      disk_size_gb         = number
      storage_account_type = optional(string, "Premium_LRS")
      caching              = optional(string, "ReadOnly")
    })), {})
  }))

  validation {
    condition     = alltrue([for vm in var.vms : can(regex("^vm-[a-z0-9-]+-[0-9]{3}$", vm.name))])
    error_message = "VM names must follow vm-<workload>-<env>-<region>-001."
  }

  validation {
    condition     = alltrue([for vm in var.vms : try(vm.computer_name, null) == null || can(regex("^[A-Za-z0-9-]{1,15}$", vm.computer_name))])
    error_message = "Windows computer_name must be 1-15 characters and contain only letters, numbers, and hyphens."
  }
}

variable "boot_diagnostics_storage_uri" {
  description = "Optional storage account URI for boot diagnostics."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to all VM resources."
  type        = map(string)
  default     = {}
}
