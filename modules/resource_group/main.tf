# ==============================================================================
# RESOURCE GROUPS (FOR_EACH FROM NESTED MAP)
# ==============================================================================
resource "azurerm_resource_group" "rg" {
  for_each = var.resource_groups

  name     = each.value.name
  location = each.value.location
  tags     = each.value.tags
}

