output "storage_account_name" { value = azurerm_storage_account.this.name }
output "container_names" { value = [for c in azurerm_storage_container.this : c.name] }
output "endpoints" { value = azurerm_storage_account.this.primary_blob_endpoint }
