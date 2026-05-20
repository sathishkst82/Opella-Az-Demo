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

variable "ssh_public_key" {
  type = string
}
