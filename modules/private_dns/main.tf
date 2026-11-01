# ==============================================================================
# PRIVATE DNS ZONES (FOR_EACH FROM NESTED MAP)
# ==============================================================================
resource "azurerm_private_dns_zone" "dns_zone" {
  for_each            = var.private_dns_zones
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  tags                = each.value.tags
}

# ==============================================================================
# VIRTUAL NETWORK LINKS (FLATTENED FROM NESTED MAP)
# ==============================================================================
locals {
  vnet_links_flat = {
    for link in flatten([
      for zone_key, zone_val in var.private_dns_zones : [
        for vnet_name in coalesce(zone_val.linked_vnets, []) : {
          key                 = "${zone_key}-${vnet_name}"
          zone_key            = zone_key
          zone_name           = azurerm_private_dns_zone.dns_zone[zone_key].name
          resource_group_name = zone_val.resource_group_name
          vnet_name           = vnet_name
          vnet_id             = contains(keys(var.vnet_ids_by_name), vnet_name) ? var.vnet_ids_by_name[vnet_name] : vnet_name
          tags                = zone_val.tags
        }
      ]
    ]) : link.key => link
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_links" {
  for_each             = local.vnet_links_flat
  name                 = "link-${each.value.vnet_name}-${replace(each.value.zone_name, ".", "-")}"
  private_dns_zone_id  = azurerm_private_dns_zone.dns_zone[each.value.zone_key].id
  virtual_network_id   = each.value.vnet_id
  registration_enabled = false
  tags                 = each.value.tags
}

# ==============================================================================
# PRIVATE DNS A RECORDS (FLATTENED FROM NESTED MAP & STANDALONE MAP)
# ==============================================================================
locals {
  # 1. Flatten a_records defined directly inside private_dns_zones nested map
  nested_a_records_flat = {
    for pair in flatten([
      for zone_key, zone_val in var.private_dns_zones : [
        for rec_key, rec_val in coalesce(zone_val.a_records, {}) : {
          key                 = "${zone_key}-${rec_key}"
          name                = rec_val.name
          private_dns_zone_id = azurerm_private_dns_zone.dns_zone[zone_key].id
          ttl                 = coalesce(rec_val.ttl, 300)
          records             = length(coalesce(rec_val.records, [])) > 0 ? rec_val.records : (rec_val.ip_address != null ? [rec_val.ip_address] : [])
          tags                = coalesce(rec_val.tags, zone_val.tags, {})
        }
      ]
    ]) : pair.key => pair
  }

  # 2. Flatten standalone var.dns_a_records
  standalone_a_records_flat = {
    for k, v in var.dns_a_records :
    k => {
      name                = v.name
      private_dns_zone_id = coalesce(v.private_dns_zone_id, try(azurerm_private_dns_zone.dns_zone[v.zone_key].id, null))
      ttl                 = coalesce(v.ttl, 300)
      records             = length(coalesce(v.records, [])) > 0 ? v.records : (v.ip_address != null ? [v.ip_address] : [])
      tags                = coalesce(v.tags, {})
    }
  }

  all_a_records = merge(local.nested_a_records_flat, local.standalone_a_records_flat)
}

resource "azurerm_private_dns_a_record" "a_records" {
  for_each = local.all_a_records

  name                = each.value.name
  private_dns_zone_id = each.value.private_dns_zone_id
  ttl                 = each.value.ttl
  records             = each.value.records
  tags                = each.value.tags
}
