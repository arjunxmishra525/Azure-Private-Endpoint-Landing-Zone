variable "private_endpoints" {
  description = "Dictionary of Private Endpoints to create"
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

variable "subnet_ids_by_name" {
  description = "Lookup map: Subnet Name => Resource ID"
  type        = map(string)
  default     = {}
}

variable "storage_account_ids" {
  description = "Lookup map: Storage Account Key => Resource ID"
  type        = map(string)
  default     = {}
}

variable "dns_zone_ids" {
  description = "Lookup map: DNS Zone Key => Resource ID"
  type        = map(string)
  default     = {}
}

