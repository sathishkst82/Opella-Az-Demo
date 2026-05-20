variable "resource_group_id" {
  type = string
}

variable "location" {
  type = string
}

variable "required_tags" {
  type    = list(string)
  default = ["Environment", "Project", "ManagedBy", "Owner", "CostCenter", "Region", "Application"]
}
