variable "location" {
  type    = string
  default = "eastus"
}

variable "project" {
  type    = string
  default = "opella"
}

variable "owner" {
  type    = string
  default = "platform-team"
}

variable "cost_center" {
  type    = string
  default = "CC1001"
}

variable "admin_password" {
  type      = string
  sensitive = true

  validation {
    condition     = length(var.admin_password) >= 14
    error_message = "admin_password must be at least 14 characters."
  }
}
