output "vm_ids" {
  description = "Windows VM IDs keyed by VM key."
  value       = { for key, vm in azurerm_windows_virtual_machine.this : key => vm.id }
}

output "vm_names" {
  description = "Windows VM names keyed by VM key."
  value       = { for key, vm in azurerm_windows_virtual_machine.this : key => vm.name }
}

output "private_ips" {
  description = "Private IP addresses keyed by VM key."
  value       = { for key, nic in azurerm_network_interface.this : key => nic.private_ip_address }
}

output "public_ips" {
  description = "Public IP addresses keyed by VM key."
  value       = { for key, pip in azurerm_public_ip.this : key => pip.ip_address }
}

output "principal_ids" {
  description = "System-assigned managed identity principal IDs."
  value       = { for key, vm in azurerm_windows_virtual_machine.this : key => vm.identity[0].principal_id }
}
