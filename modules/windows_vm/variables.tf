variable "windows_vms" {
  description = "Dictionary of Windows Workload VMs (In Spoke VNet Subnet)"
  type = map(object({
    name                 = string
    resource_group_name  = string
    location             = string
    virtual_network_name = string
    subnet_name          = string
    vm_size              = optional(string, "Standard_B2ats_v2")
    admin_username       = optional(string, "azureuser")
    admin_password       = optional(string, null)
    enable_public_ip     = optional(bool, true)
    allowed_rdp_cidr     = optional(string, "*")
    os_disk = optional(object({
      caching              = optional(string, "ReadWrite")
      storage_account_type = optional(string, "StandardSSD_LRS")
    }), {})
    image = optional(object({
      publisher = optional(string, "MicrosoftWindowsServer")
      offer     = optional(string, "WindowsServer")
      sku       = optional(string, "2022-datacenter-azure-edition")
      version   = optional(string, "latest")
    }), {})
    tags = optional(map(string), {})
  }))
}

variable "subnet_ids_by_name" {
  description = "Lookup map: Subnet Name => Resource ID"
  type        = map(string)
  default     = {}
}

