output "resource_group_name" {
  description = "Environment resource group name."
  value       = azurerm_resource_group.this.name
}

output "vnet_id" {
  description = "Virtual network ID."
  value       = module.network.vnet_id
}

output "subnet_ids" {
  description = "Subnet IDs."
  value       = module.network.subnet_ids
}

output "storage_account_name" {
  description = "Storage account name."
  value       = module.storage.storage_account_name
}

output "vm_private_ips" {
  description = "VM private IPs."
  value       = module.vm.private_ips
}

output "policy_assignment_id" {
  description = "Governance baseline policy assignment ID."
  value       = module.governance.assignment_id
}
