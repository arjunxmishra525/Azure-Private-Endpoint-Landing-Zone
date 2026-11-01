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

