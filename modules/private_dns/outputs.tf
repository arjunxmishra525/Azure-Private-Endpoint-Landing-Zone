output "dns_zones" {
  description = "Map of created Private DNS Zones"
  value       = azurerm_private_dns_zone.dns_zone
}

output "dns_zone_ids_by_key" {
  description = "Lookup map: DNS Zone Key => Resource ID"
  value       = { for k, v in azurerm_private_dns_zone.dns_zone : k => v.id }
}

output "dns_zone_names_by_key" {
  description = "Lookup map: DNS Zone Key => Zone Name"
  value       = { for k, v in azurerm_private_dns_zone.dns_zone : k => v.name }
}

output "dns_a_records" {
  description = "Map of created Private DNS A records"
  value       = azurerm_private_dns_a_record.a_records
}

output "vnet_links" {
  description = "Map of created Virtual Network Links"
  value       = azurerm_private_dns_zone_virtual_network_link.vnet_links
}

