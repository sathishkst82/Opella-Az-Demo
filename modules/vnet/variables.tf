variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "vnet_name" { type = string }
variable "address_space" { type = list(string) }
variable "subnets" {
  type = map(object({
    address_prefixes  = list(string)
    service_endpoints = optional(list(string), [])
    delegations = optional(list(object({
      name         = string
      service_name = string
      actions      = list(string)
    })), [])
  }))
}
variable "dns_servers" { type = list(string) default = null }
variable "tags" { type = map(string) default = {} }
variable "service_endpoints" { type = list(string) default = [] }
variable "delegations" { type = list(any) default = [] }
variable "nsg_rules" { type = map(any) default = {} }
variable "route_tables" { type = map(any) default = {} }
variable "private_dns_links" { type = map(any) default = {} }
variable "enable_ddos" { type = bool default = false }
variable "ddos_plan_id" { type = string default = null }
variable "prevent_destroy" { type = bool default = true }
