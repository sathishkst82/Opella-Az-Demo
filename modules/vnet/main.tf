locals {
  normalized_tags = merge(var.tags, {
    Module = "vnet"
  })

  subnet_delegations = {
    for key, subnet in var.subnets : key => length(try(subnet.delegations, [])) > 0 ? subnet.delegations : lookup(var.delegations, key, [])
  }

  subnet_service_endpoints = {
    for key, subnet in var.subnets : key => length(try(subnet.service_endpoints, [])) > 0 ? subnet.service_endpoints : var.service_endpoints
  }

  nsg_enabled_subnets = {
    for key, subnet in var.subnets : key => subnet
    if try(subnet.create_nsg, true)
  }

  subnet_nsg_rules = {
    for key, subnet in var.subnets : key => concat(
      [for rule_name in try(subnet.nsg_rules, []) : one([for rule in lookup(var.nsg_rules, key, []) : rule if rule.name == rule_name])],
      length(try(subnet.nsg_rules, [])) == 0 ? lookup(var.nsg_rules, key, []) : []
    )
  }

  subnet_route_table_associations = {
    for key, subnet in var.subnets : key => subnet.route_table
    if try(subnet.route_table, null) != null
  }
}

resource "azurerm_network_ddos_protection_plan" "this" {
  count               = var.enable_ddos ? 1 : 0
  name                = replace(var.vnet_name, "vnet-", "ddos-")
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.normalized_tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  dns_servers         = var.dns_servers
  tags                = local.normalized_tags

  dynamic "ddos_protection_plan" {
    for_each = var.enable_ddos ? azurerm_network_ddos_protection_plan.this : []
    content {
      id     = ddos_protection_plan.value.id
      enable = true
    }
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [tags["LastPatchedBy"]]
  }
}

resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                                          = each.value.name
  resource_group_name                           = var.resource_group_name
  virtual_network_name                          = azurerm_virtual_network.this.name
  address_prefixes                              = each.value.address_prefixes
  service_endpoints                             = local.subnet_service_endpoints[each.key]
  private_endpoint_network_policies_enabled     = each.value.private_endpoint_network_policies_enabled
  private_link_service_network_policies_enabled = each.value.private_link_service_network_policies_enabled

  dynamic "delegation" {
    for_each = local.subnet_delegations[each.key]
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_network_security_group" "this" {
  for_each = local.nsg_enabled_subnets

  name                = "nsg-${each.value.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.normalized_tags

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [tags["LastPatchedBy"]]
  }
}

resource "azurerm_network_security_rule" "this" {
  for_each = {
    for item in flatten([
      for subnet_key, rules in local.subnet_nsg_rules : [
        for rule in rules : merge(rule, {
          subnet_key = subnet_key
        })
      ]
    ]) : "${item.subnet_key}-${item.name}" => item
    if contains(keys(azurerm_network_security_group.this), item.subnet_key)
  }

  name                         = each.value.name
  priority                     = each.value.priority
  direction                    = each.value.direction
  access                       = each.value.access
  protocol                     = each.value.protocol
  source_port_range            = try(each.value.source_port_range, null)
  source_port_ranges           = try(each.value.source_port_ranges, null)
  destination_port_range       = try(each.value.destination_port_range, null)
  destination_port_ranges      = try(each.value.destination_port_ranges, null)
  source_address_prefix        = try(each.value.source_address_prefix, null)
  source_address_prefixes      = try(each.value.source_address_prefixes, null)
  destination_address_prefix   = try(each.value.destination_address_prefix, null)
  destination_address_prefixes = try(each.value.destination_address_prefixes, null)
  description                  = try(each.value.description, null)
  resource_group_name          = var.resource_group_name
  network_security_group_name  = azurerm_network_security_group.this[each.value.subnet_key].name
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = azurerm_network_security_group.this

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = each.value.id
}

resource "azurerm_route_table" "this" {
  for_each = var.route_tables

  name                          = each.key
  location                      = var.location
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = each.value.disable_bgp_route_propagation
  tags                          = local.normalized_tags

  dynamic "route" {
    for_each = each.value.routes
    content {
      name                   = route.value.name
      address_prefix         = route.value.address_prefix
      next_hop_type          = route.value.next_hop_type
      next_hop_in_ip_address = try(route.value.next_hop_in_ip_address, null)
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_subnet_route_table_association" "this" {
  for_each = local.subnet_route_table_associations

  subnet_id      = azurerm_subnet.this[each.key].id
  route_table_id = azurerm_route_table.this[each.value].id
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = var.private_dns_links

  name                  = "pdnslink-${var.vnet_name}-${replace(each.key, ".", "-")}"
  resource_group_name   = each.value.resource_group_name
  private_dns_zone_name = each.key
  virtual_network_id    = azurerm_virtual_network.this.id
  registration_enabled  = each.value.registration_enabled
  tags                  = local.normalized_tags

  lifecycle {
    create_before_destroy = true
  }
}
