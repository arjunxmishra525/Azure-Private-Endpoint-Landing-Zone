variable "private_dns_zones" {
  description = "Dictionary of Private DNS Zones with nested A records and VNet links"
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

variable "vnet_ids_by_name" {
  description = "Map of Virtual Network Name to Virtual Network Resource ID"
  type        = map(string)
  default     = {}
}

variable "dns_a_records" {
  description = "Dictionary of standalone DNS A records to create in private DNS zones"
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

