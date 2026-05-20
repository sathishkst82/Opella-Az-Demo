output "vnet_id" { value = azurerm_virtual_network.this.id }
output "vnet_name" { value = azurerm_virtual_network.this.name }
output "resource_group_name" { value = var.resource_group_name }
output "subnet_ids" { value = { for k, s in azurerm_subnet.this : k => s.id } }
output "subnet_names" { value = keys(azurerm_subnet.this) }
