variable "project" {
  description = "Project or platform short name."
  type        = string
  default     = "opella"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "uat"
}

variable "location" {
  description = "Primary Azure region."
  type        = string
  default     = "eastus"
}

variable "location_short" {
  description = "Short Azure region code used in names."
  type        = string
  default     = "eus"
}

variable "owner" {
  description = "Business or engineering owner."
  type        = string
  default     = "platform-engineering"
}

variable "cost_center" {
  description = "Cost center for chargeback."
  type        = string
  default     = "cc-platform"
}

variable "application" {
  description = "Application or platform name."
  type        = string
  default     = "ai-devops-orchestration"
}

variable "admin_username" {
  description = "Windows VM admin username."
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Windows VM local administrator password. Store this in GitHub Environment secrets or a local tfvars file outside source control."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.admin_password) >= 14
    error_message = "admin_password must be at least 14 characters."
  }
}

variable "allowed_locations" {
  description = "Allowed Azure regions for governance."
  type        = list(string)
  default     = ["eastus"]
}
