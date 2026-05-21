output "vnet_id" {
  description = "Virtual network resource ID."
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Virtual network name."
  value       = azurerm_virtual_network.this.name
}

output "resource_group_name" {
  description = "Resource group name."
  value       = var.resource_group_name
}

output "subnet_ids" {
  description = "Subnet IDs keyed by subnet key."
  value       = { for key, subnet in azurerm_subnet.this : key => subnet.id }
}

output "subnet_names" {
  description = "Subnet names keyed by subnet key."
  value       = { for key, subnet in azurerm_subnet.this : key => subnet.name }
}
