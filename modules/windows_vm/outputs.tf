output "windows_vms" {
  description = "Map of created Windows Virtual Machines"
  value       = azurerm_windows_virtual_machine.vm
}

output "vm_ids" {
  description = "Lookup map: VM Key => Resource ID"
  value       = { for k, v in azurerm_windows_virtual_machine.vm : k => v.id }
}

output "vm_names" {
  description = "Lookup map: VM Key => VM Name"
  value       = { for k, v in azurerm_windows_virtual_machine.vm : k => v.name }
}

output "vm_private_ips" {
  description = "Lookup map: VM Key => Private IP Address"
  value       = { for k, v in azurerm_windows_virtual_machine.vm : k => v.private_ip_address }
}

output "vm_public_ips" {
  description = "Lookup map: VM Key => Public IP Address"
  value = {
    for k, v in azurerm_public_ip.pip : k => v.ip_address
  }
}

output "vm_admin_passwords" {
  description = "Lookup map: VM Key => Admin Password"
  value = {
    for k, v in var.windows_vms :
    k => v.admin_password != null ? v.admin_password : random_password.admin_password[k].result
  }
  sensitive = true
}

