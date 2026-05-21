variable "initiative_name" {
  description = "Policy initiative display name."
  type        = string
  default     = "Sathish-Governance-Baseline"
}

variable "policy_name_prefix" {
  description = "Unique prefix for subscription-level policy definition names."
  type        = string
  default     = "sathish"
}

variable "assignment_scope" {
  description = "Azure scope where the policy initiative is assigned."
  type        = string
}

variable "allowed_locations" {
  description = "Allowed Azure locations."
  type        = list(string)
}

variable "required_tags" {
  description = "Required tag names."
  type        = list(string)
}

variable "enforcement_mode" {
  description = "Policy assignment enforcement mode."
  type        = string
  default     = "Default"

  validation {
    condition     = contains(["Default", "DoNotEnforce"], var.enforcement_mode)
    error_message = "enforcement_mode must be Default or DoNotEnforce."
  }
}

