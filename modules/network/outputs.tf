output "vnets" {
  description = "Map of created Virtual Networks"
  value       = azurerm_virtual_network.vnet
}

output "vnet_ids_by_name" {
  description = "Lookup map: VNet Name => Resource ID"
  value       = { for k, v in azurerm_virtual_network.vnet : v.name => v.id }
}

output "vnet_ids_by_key" {
  description = "Lookup map: VNet Key => Resource ID"
  value       = { for k, v in azurerm_virtual_network.vnet : k => v.id }
}

output "subnets" {
  description = "Map of created Subnets"
  value       = azurerm_subnet.subnet
}

output "subnet_ids_by_name" {
  description = "Lookup map: Subnet Name => Resource ID"
  value       = { for k, v in azurerm_subnet.subnet : v.name => v.id }
}

output "subnet_ids_by_key" {
  description = "Lookup map: Subnet Key => Resource ID"
  value       = { for k, v in azurerm_subnet.subnet : k => v.id }
}

output "vnet_peerings" {
  description = "Map of created VNet Peerings"
  value       = azurerm_virtual_network_peering.peering
}

