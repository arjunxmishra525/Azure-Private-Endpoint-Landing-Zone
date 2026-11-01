# ==============================================================================
# ROOT VARIABLES: NESTED MAP / DICTIONARY STRUCTURES
# ==============================================================================

variable "resource_groups" {
  description = "Dictionary of Azure Resource Groups"
  type = map(object({
    name     = string
    location = string
    tags     = optional(map(string), {})
  }))
}

variable "vnets" {
  description = "Dictionary of Virtual Networks (Hub and Spoke)"
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    address_space       = list(string)
    tags                = optional(map(string), {})
  }))
}

variable "subnets" {
  description = "Dictionary of Subnets for Hub and Spoke VNets"
  type = map(object({
    name                 = string
    resource_group_name  = string
    virtual_network_name = string
    address_prefixes     = list(string)
  }))
}

variable "vnet_peerings" {
  description = "Dictionary of Bidirectional VNet Peerings"
  type = map(object({
    name                         = string
    resource_group_name          = string
    virtual_network_name         = string
    remote_virtual_network_name  = string
    allow_virtual_network_access = optional(bool, true)
    allow_forwarded_traffic      = optional(bool, true)
  }))
  default = {}
}

variable "storage_accounts" {
  description = "Dictionary of Storage Accounts (In Hub VNet context)"
  type = map(object({
    name                          = string
    use_random_suffix             = optional(bool, true)
    resource_group_name           = string
    location                      = string
    account_tier                  = optional(string, "Standard")
    account_replication_type      = optional(string, "LRS")
    account_kind                  = optional(string, "StorageV2")
    min_tls_version               = optional(string, "TLS1_2")
    public_network_access_enabled = optional(bool, false)
    tags                          = optional(map(string), {})
    containers = optional(map(object({
      name                  = string
      container_access_type = optional(string, "private")
    })), {})
  }))
}

variable "private_dns_zones" {
  description = "Dictionary of Private DNS Zones (In Hub VNet with nested A records)"
  type = map(object({
    name                = string
    resource_group_name = string
    linked_vnets        = optional(list(string), [])
    tags                = optional(map(string), {})
    a_records = optional(map(object({
      name       = string
      records    = optional(list(string), [])
      ip_address = optional(string, null)
      ttl        = optional(number, 300)
      tags       = optional(map(string), {})
    })), {})
  }))
}

variable "dns_a_records" {
  description = "Dictionary of standalone Private DNS A Records (optional)"
  type = map(object({
    name                = string
    records             = optional(list(string), [])
    ip_address          = optional(string, null)
    ttl                 = optional(number, 300)
    zone_key            = optional(string, null)
    private_dns_zone_id = optional(string, null)
    tags                = optional(map(string), {})
  }))
  default = {}
}

variable "private_endpoints" {
  description = "Dictionary of Private Endpoints (In Hub VNet Subnet)"
  type = map(object({
    name                 = string
    resource_group_name  = string
    location             = string
    virtual_network_name = string
    subnet_name          = string
    storage_account_key  = string
    subresource_names    = optional(list(string), ["blob"])
    private_dns_zone_key = optional(string, null)
    dns_zone_group_name  = optional(string, "blob-dns-zone-group")
    tags                 = optional(map(string), {})
  }))
}

variable "windows_vms" {
  description = "Dictionary of Windows Workload VMs (In Spoke VNet Subnet, size: Standard_B2ats_v2)"
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

