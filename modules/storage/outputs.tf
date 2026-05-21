output "storage_account_name" {
  description = "Storage account name."
  value       = azurerm_storage_account.this.name
}

output "storage_account_id" {
  description = "Storage account ID."
  value       = azurerm_storage_account.this.id
}

output "container_names" {
  description = "Blob container names keyed by container key."
  value       = { for key, container in azurerm_storage_container.this : key => container.name }
}

output "primary_blob_endpoint" {
  description = "Primary blob endpoint."
  value       = azurerm_storage_account.this.primary_blob_endpoint
}

output "primary_dfs_endpoint" {
  description = "Primary DFS endpoint."
  value       = azurerm_storage_account.this.primary_dfs_endpoint
}
