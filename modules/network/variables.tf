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

