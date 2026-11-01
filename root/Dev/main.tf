# ==============================================================================
# ROOT MODULE: ORCHESTRATION VIA NESTED MAP INPUTS
# ==============================================================================

# 1. Resource Groups Module
module "resource_group" {
  source          = "../../modules/resource_group"
  resource_groups = var.resource_groups
}

# 2. Hub & Spoke Networking Module (VNets, Subnets, and Peerings)
module "network" {
  source     = "../../modules/network"
  depends_on = [module.resource_group]

  vnets         = var.vnets
  subnets       = var.subnets
  vnet_peerings = var.vnet_peerings
}

# 3. Storage Account & Blob Containers (In Hub VNet Context)
module "storage" {
  source     = "../../modules/storage"
  depends_on = [module.resource_group]

  storage_accounts = var.storage_accounts
}

# 4. Private DNS Zone, VNet Links & A Records (In Hub VNet Context)
module "private_dns" {
  source     = "../../modules/private_dns"
  depends_on = [module.resource_group, module.network]

  private_dns_zones = var.private_dns_zones
  vnet_ids_by_name  = module.network.vnet_ids_by_name
  dns_a_records     = var.dns_a_records
}

# 5. Private Endpoints (In Hub VNet Subnet with DNS Zone Group)
module "private_endpoint" {
  source     = "../../modules/private_endpoint"
  depends_on = [module.network, module.storage, module.private_dns]

  private_endpoints   = var.private_endpoints
  subnet_ids_by_name  = module.network.subnet_ids_by_name
  storage_account_ids = module.storage.storage_account_ids
  dns_zone_ids        = module.private_dns.dns_zone_ids_by_key
}

# 6. Windows Virtual Machines (Workload in Spoke VNet Subnet, Standard_B2ats_v2)
module "windows_vm" {
  source     = "../../modules/windows_vm"
  depends_on = [module.network]

  windows_vms        = var.windows_vms
  subnet_ids_by_name = module.network.subnet_ids_by_name
}

