# ==============================================================================
# PRIVATE ENDPOINTS (FOR_EACH FROM NESTED MAP)
# ==============================================================================
resource "azurerm_private_endpoint" "pe" {
  for_each            = var.private_endpoints
  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  subnet_id           = var.subnet_ids_by_name[each.value.subnet_name]

  private_service_connection {
    name                           = "psc-${each.value.name}"
    private_connection_resource_id = var.storage_account_ids[each.value.storage_account_key]
    is_manual_connection           = false
    subresource_names              = coalesce(each.value.subresource_names, ["blob"])
  }

  dynamic "private_dns_zone_group" {
    for_each = each.value.private_dns_zone_key != null ? [1] : []
    content {
      name                 = coalesce(each.value.dns_zone_group_name, "blob-dns-zone-group")
      private_dns_zone_ids = [var.dns_zone_ids[each.value.private_dns_zone_key]]
    }
  }

  tags = each.value.tags
}

