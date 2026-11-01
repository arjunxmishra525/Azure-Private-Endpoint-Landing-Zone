output "private_endpoints" {
  description = "Map of created Private Endpoints"
  value       = azurerm_private_endpoint.pe
}

output "private_ip_addresses" {
  description = "Lookup map: Private Endpoint Key => Private IP Address"
  value = {
    for k, v in azurerm_private_endpoint.pe :
    k => try(v.private_service_connection[0].private_ip_address, try(v.custom_dns_configs[0].ip_addresses[0], null))
  }
}

