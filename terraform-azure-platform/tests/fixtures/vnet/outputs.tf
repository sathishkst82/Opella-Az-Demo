output "subnet_ids" {
  description = "Subnet IDs from the module."
  value       = module.vnet.subnet_ids
}

output "subnet_names" {
  description = "Subnet names from the module."
  value       = module.vnet.subnet_names
}
