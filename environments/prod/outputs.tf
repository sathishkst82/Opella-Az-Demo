output "resource_group_name" { value = azurerm_resource_group.this.name }
output "vnet_id" { value = module.vnet.vnet_id }
output "subnet_ids" { value = module.vnet.subnet_ids }
output "vm_names" { value = module.vm.vm_names }
output "storage_account_name" { value = module.storage.storage_account_name }
