variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "admin_password" {
  type      = string
  sensitive = true

  validation {
    condition     = length(var.admin_password) >= 14
    error_message = "admin_password must be at least 14 characters."
  }
}

variable "boot_diagnostics_storage_uri" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "vms" {
  type = map(object({
    subnet_id        = string
    vm_size          = string
    enable_public_ip = bool
    computer_name    = string
  }))
}
