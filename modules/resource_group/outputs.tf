output "resource_groups" {
  description = "Map of created Resource Groups"
  value       = azurerm_resource_group.rg
}

output "resource_group_names" {
  description = "Lookup map: Key => Resource Group Name"
  value       = { for k, v in azurerm_resource_group.rg : k => v.name }
}

output "resource_group_ids" {
  description = "Lookup map: Key => Resource Group ID"
  value       = { for k, v in azurerm_resource_group.rg : k => v.id }
}

