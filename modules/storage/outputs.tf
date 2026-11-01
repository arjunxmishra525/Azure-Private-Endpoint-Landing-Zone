output "storage_accounts" {
  description = "Map of created Storage Accounts"
  value       = azurerm_storage_account.sa
}

output "storage_account_ids" {
  description = "Lookup map: Storage Key => Resource ID"
  value       = { for k, v in azurerm_storage_account.sa : k => v.id }
}

output "storage_account_names" {
  description = "Lookup map: Storage Key => Account Name"
  value       = { for k, v in azurerm_storage_account.sa : k => v.name }
}

output "storage_primary_blob_endpoints" {
  description = "Lookup map: Storage Key => Primary Blob Endpoint URL"
  value       = { for k, v in azurerm_storage_account.sa : k => v.primary_blob_endpoint }
}

output "storage_containers" {
  description = "Map of created Storage Containers"
  value       = azurerm_storage_container.sc
}

