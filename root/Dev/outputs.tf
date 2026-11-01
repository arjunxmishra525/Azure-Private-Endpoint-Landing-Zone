# ==============================================================================
# ROOT OUTPUTS (AGGREGATED FROM MODULE DICTIONARIES)
# ==============================================================================

output "resource_groups" {
  description = "Created Resource Groups"
  value       = { for k, v in module.resource_group.resource_groups : k => v.name }
}

output "vnets" {
  description = "Created Virtual Networks"
  value       = { for k, v in module.network.vnets : k => v.name }
}

output "subnets" {
  description = "Created Subnets"
  value       = { for k, v in module.network.subnets : k => v.name }
}

output "storage_account_names" {
  description = "Created Storage Account Names"
  value       = module.storage.storage_account_names
}

output "storage_primary_blob_endpoints" {
  description = "Storage Primary Blob Service Endpoints"
  value       = module.storage.storage_primary_blob_endpoints
}

output "private_endpoint_ips" {
  description = "Private IP addresses assigned to Private Endpoints in Hub VNet"
  value       = module.private_endpoint.private_ip_addresses
}

output "private_dns_zones" {
  description = "Created Private DNS Zones"
  value       = module.private_dns.dns_zone_names_by_key
}

output "private_dns_a_records" {
  description = "Created Private DNS A Records"
  value       = { for k, v in module.private_dns.dns_a_records : k => v.name }
}

output "vm_private_ips" {
  description = "Private IPs of Windows VMs in Spoke VNet"
  value       = module.windows_vm.vm_private_ips
}

output "vm_public_ips" {
  description = "Public IPs of Windows VMs (for RDP)"
  value       = module.windows_vm.vm_public_ips
}

output "vm_admin_passwords" {
  description = "Admin Passwords for Windows VMs (sensitive)"
  value       = module.windows_vm.vm_admin_passwords
  sensitive   = true
}

output "rdp_connection_commands" {
  description = "Commands to RDP into the Windows VMs"
  value = {
    for k, ip in module.windows_vm.vm_public_ips :
    k => ip != null ? "mstsc /v:${ip}" : "Public IP is disabled for ${k}"
  }
}

output "powershell_verification_commands" {
  description = "Commands to execute in Windows VM PowerShell to verify Private Endpoint resolution across Hub-Spoke peering"
  value = {
    for pe_key, pe_val in var.private_endpoints :
    pe_key => <<-EOT
      # 1. Test DNS resolution (resolves to private IP in Hub PE subnet)
      Resolve-DnsName -Name ${module.storage.storage_account_names[pe_val.storage_account_key]}.blob.core.windows.net

      # 2. Test TCP 443 connectivity to Blob storage via Private Endpoint
      Test-NetConnection -ComputerName ${module.storage.storage_account_names[pe_val.storage_account_key]}.blob.core.windows.net -Port 443
    EOT
  }
}

