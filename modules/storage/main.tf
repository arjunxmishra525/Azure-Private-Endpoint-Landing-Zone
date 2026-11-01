# ==============================================================================
# RANDOM SUFFIX FOR GLOBALLY UNIQUE STORAGE ACCOUNT NAMES
# ==============================================================================
resource "random_string" "stg_suffix" {
  for_each = {
    for k, v in var.storage_accounts : k => v
    if coalesce(v.use_random_suffix, true)
  }

  length  = 6
  special = false
  upper   = false
}

# ==============================================================================
# STORAGE ACCOUNTS (FOR_EACH FROM NESTED MAP)
# ==============================================================================
resource "azurerm_storage_account" "sa" {
  for_each = var.storage_accounts

  name = lower(
    coalesce(each.value.use_random_suffix, true)
    ? substr("${each.value.name}${random_string.stg_suffix[each.key].result}", 0, 24)
    : substr(each.value.name, 0, 24)
  )

  resource_group_name           = each.value.resource_group_name
  location                      = each.value.location
  account_tier                  = coalesce(each.value.account_tier, "Standard")
  account_replication_type      = coalesce(each.value.account_replication_type, "LRS")
  account_kind                  = coalesce(each.value.account_kind, "StorageV2")
  min_tls_version               = coalesce(each.value.min_tls_version, "TLS1_2")
  public_network_access_enabled = coalesce(each.value.public_network_access_enabled, false)
  tags                          = each.value.tags
}

# ==============================================================================
# BLOB CONTAINERS (FLATTENED FROM NESTED MAP)
# ==============================================================================
locals {
  containers_flat = {
    for cnt in flatten([
      for stg_key, stg_val in var.storage_accounts : [
        for cnt_key, cnt_val in coalesce(stg_val.containers, {}) : {
          key                   = "${stg_key}-${cnt_key}"
          stg_key               = stg_key
          name                  = cnt_val.name
          container_access_type = coalesce(cnt_val.container_access_type, "private")
        }
      ]
    ]) : cnt.key => cnt
  }
}

resource "azurerm_storage_container" "sc" {
  for_each              = local.containers_flat
  name                  = each.value.name
  storage_account_id    = azurerm_storage_account.sa[each.value.stg_key].id
  container_access_type = each.value.container_access_type
}
