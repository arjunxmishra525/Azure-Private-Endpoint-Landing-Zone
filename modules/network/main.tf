# ==============================================================================
# VIRTUAL NETWORKS (FOR_EACH FROM NESTED MAP)
# ==============================================================================
resource "azurerm_virtual_network" "vnet" {
  for_each            = var.vnets
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  address_space       = each.value.address_space
  tags                = each.value.tags
}

# ==============================================================================
# SUBNETS (FOR_EACH FROM NESTED MAP)
# ==============================================================================
resource "azurerm_subnet" "subnet" {
  for_each             = var.subnets
  name                 = each.value.name
  resource_group_name  = each.value.resource_group_name
  virtual_network_name = each.value.virtual_network_name
  address_prefixes     = each.value.address_prefixes

  depends_on = [azurerm_virtual_network.vnet]
}

# ==============================================================================
# BIDIRECTIONAL VNET PEERINGS (FOR_EACH FROM NESTED MAP)
# ==============================================================================
locals {
  # Build a lookup map of VNet name => VNet resource ID
  vnet_ids_by_name = {
    for k, v in azurerm_virtual_network.vnet : v.name => v.id
  }
}

resource "azurerm_virtual_network_peering" "peering" {
  for_each = var.vnet_peerings

  name                         = each.value.name
  resource_group_name          = each.value.resource_group_name
  virtual_network_name         = each.value.virtual_network_name
  remote_virtual_network_id    = contains(keys(local.vnet_ids_by_name), each.value.remote_virtual_network_name) ? local.vnet_ids_by_name[each.value.remote_virtual_network_name] : each.value.remote_virtual_network_name
  allow_virtual_network_access = coalesce(each.value.allow_virtual_network_access, true)
  allow_forwarded_traffic      = coalesce(each.value.allow_forwarded_traffic, true)

  depends_on = [azurerm_subnet.subnet]
}

