variable "resource_group_name" {
  description = "Name of the resource group containing the virtual network."
  type        = string

  validation {
    condition     = length(var.resource_group_name) >= 1 && length(var.resource_group_name) <= 90
    error_message = "resource_group_name must be between 1 and 90 characters."
  }
}

variable "location" {
  description = "Azure region for network resources."
  type        = string
}

variable "vnet_name" {
  description = "Virtual network name."
  type        = string

  validation {
    condition     = can(regex("^vnet-[a-z0-9-]+$", var.vnet_name))
    error_message = "vnet_name must follow the pattern vnet-<workload>-<env>-<region>."
  }
}

variable "address_space" {
  description = "List of CIDR ranges for the virtual network."
  type        = list(string)

  validation {
    condition     = length(var.address_space) > 0
    error_message = "At least one VNET CIDR range is required."
  }
}

variable "subnets" {
  description = "Subnet map keyed by logical subnet name."
  type = map(object({
    name                                          = string
    address_prefixes                              = list(string)
    private_endpoint_network_policies_enabled     = optional(bool, true)
    private_link_service_network_policies_enabled = optional(bool, true)
    service_endpoints                             = optional(list(string), [])
    delegations = optional(list(object({
      name = string
      service_delegation = object({
        name    = string
        actions = optional(list(string), [])
      })
    })), [])
    create_nsg  = optional(bool, true)
    nsg_rules   = optional(list(string), [])
    route_table = optional(string)
  }))

  validation {
    condition     = alltrue([for subnet in var.subnets : length(subnet.address_prefixes) > 0])
    error_message = "Every subnet must include at least one address prefix."
  }
}

variable "dns_servers" {
  description = "Optional DNS servers for hybrid DNS forwarding."
  type        = list(string)
  default     = null
}

variable "tags" {
  description = "Tags applied to all module resources."
  type        = map(string)
  default     = {}
}

variable "service_endpoints" {
  description = "Default service endpoints applied when a subnet does not define its own list."
  type        = list(string)
  default     = []
}

variable "delegations" {
  description = "Default subnet delegations keyed by subnet key."
  type = map(list(object({
    name = string
    service_delegation = object({
      name    = string
      actions = optional(list(string), [])
    })
  })))
  default = {}
}

variable "nsg_rules" {
  description = "NSG security rules keyed by subnet key."
  type = map(list(object({
    name                         = string
    priority                     = number
    direction                    = string
    access                       = string
    protocol                     = string
    source_port_range            = optional(string)
    source_port_ranges           = optional(list(string))
    destination_port_range       = optional(string)
    destination_port_ranges      = optional(list(string))
    source_address_prefix        = optional(string)
    source_address_prefixes      = optional(list(string))
    destination_address_prefix   = optional(string)
    destination_address_prefixes = optional(list(string))
    description                  = optional(string)
  })))
  default = {}
}

variable "route_tables" {
  description = "Route tables keyed by route table name."
  type = map(object({
    disable_bgp_route_propagation = optional(bool, false)
    routes = optional(list(object({
      name                   = string
      address_prefix         = string
      next_hop_type          = string
      next_hop_in_ip_address = optional(string)
    })), [])
  }))
  default = {}
}

variable "private_dns_links" {
  description = "Private DNS zones to link to the virtual network, keyed by zone name."
  type = map(object({
    resource_group_name  = string
    registration_enabled = optional(bool, false)
  }))
  default = {}
}

variable "enable_ddos" {
  description = "Create and attach an Azure DDoS Network Protection plan."
  type        = bool
  default     = false
}

