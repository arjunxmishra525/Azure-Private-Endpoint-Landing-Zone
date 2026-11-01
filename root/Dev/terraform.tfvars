# ==============================================================================
# PRODUCTION NESTED MAP / DICTIONARY TFVARS
# ==============================================================================

# 1. Resource Groups Dictionary
resource_groups = {
  "rg_hub_spoke" = {
    name     = "rg-hubspoke-storage-prod"
    location = "eastus"
    tags = {
      Environment = "Production"
      ManagedBy   = "Terraform"
      Topology    = "Hub-and-Spoke"
    }
  }
}

# 2. Virtual Networks Dictionary (Hub and Spoke VNets)
vnets = {
  "hub_vnet" = {
    name                = "vnet-hub"
    resource_group_name = "rg-hubspoke-storage-prod"
    location            = "eastus"
    address_space       = ["10.0.0.0/16"]
    tags = {
      NetworkRole = "Hub"
      Environment = "Production"
    }
  }
  "spoke_vnet" = {
    name                = "vnet-spoke"
    resource_group_name = "rg-hubspoke-storage-prod"
    location            = "centralindia"
    address_space       = ["10.1.0.0/16"]
    tags = {
      NetworkRole = "Spoke-Workload"
      Environment = "Production"
    }
  }
}

# 3. Subnets Dictionary
# Hub hosts: Management subnet + Private Endpoint subnet
# Spoke hosts: Workload VM subnet
subnets = {
  "hub_mgmt" = {
    name                 = "snet-hub-mgmt"
    resource_group_name  = "rg-hubspoke-storage-prod"
    virtual_network_name = "vnet-hub"
    address_prefixes     = ["10.0.1.0/24"]
  }
  "hub_pe" = {
    name                 = "snet-hub-private-endpoints"
    resource_group_name  = "rg-hubspoke-storage-prod"
    virtual_network_name = "vnet-hub"
    address_prefixes     = ["10.0.2.0/24"]
  }
  "spoke_workload" = {
    name                 = "snet-spoke-workload"
    resource_group_name  = "rg-hubspoke-storage-prod"
    virtual_network_name = "vnet-spoke"
    address_prefixes     = ["10.1.1.0/24"]
  }
}

# 4. VNet Peerings Dictionary (Bidirectional Hub <-> Spoke)
vnet_peerings = {
  "hub_to_spoke" = {
    name                         = "peer-hub-to-spoke"
    resource_group_name          = "rg-hubspoke-storage-prod"
    virtual_network_name         = "vnet-hub"
    remote_virtual_network_name  = "vnet-spoke"
    allow_virtual_network_access = true
    allow_forwarded_traffic      = true
  }
  "spoke_to_hub" = {
    name                         = "peer-spoke-to-hub"
    resource_group_name          = "rg-hubspoke-storage-prod"
    virtual_network_name         = "vnet-spoke"
    remote_virtual_network_name  = "vnet-hub"
    allow_virtual_network_access = true
    allow_forwarded_traffic      = true
  }
}

# 5. Storage Accounts Dictionary (In Hub Network Context)
storage_accounts = {
  "sa_blob" = {
    name                          = "stghubprod01"
    use_random_suffix             = true
    resource_group_name           = "rg-hubspoke-storage-prod"
    location                      = "eastus"
    account_tier                  = "Standard"
    account_replication_type      = "LRS"
    account_kind                  = "StorageV2"
    min_tls_version               = "TLS1_2"
    public_network_access_enabled = false # Disables public internet; forces Private Link traffic
    tags = {
      Service     = "BlobStorage"
      Role        = "CentralDataStore"
      Environment = "Production"
    }
    containers = {
      "data" = {
        name                  = "democontainer"
        container_access_type = "private"
      }
    }
  }
}

# 6. Private DNS Zones Dictionary with NESTED MAP A Records & VNet Links
private_dns_zones = {
  "blob_dns" = {
    name                = "privatelink.blob.core.windows.net"
    resource_group_name = "rg-hubspoke-storage-prod"
    linked_vnets        = ["vnet-hub", "vnet-spoke"]
    tags = {
      Service     = "PrivateDNS"
      Environment = "Production"
    }
    # Nested Map for Private DNS A records
    a_records = {
      "stg_blob_pe_record" = {
        name       = "stghubprod01"
        ip_address = "10.0.2.4" # Pre-allocated / static Private Endpoint IP in snet-hub-private-endpoints
        ttl        = 300
        tags = {
          RecordType = "StoragePrivateEndpoint"
        }
      }
    }
  }
}

# Standalone DNS A records (optional, defaults to empty)
dns_a_records = {}

# 7. Private Endpoints Dictionary (Deployed into Hub PE Subnet)
private_endpoints = {
  "pe_blob" = {
    name                 = "pe-stghub-blob"
    resource_group_name  = "rg-hubspoke-storage-prod"
    location             = "eastus"
    virtual_network_name = "vnet-hub"
    subnet_name          = "snet-hub-private-endpoints"
    storage_account_key  = "sa_blob"
    subresource_names    = ["blob"]
    private_dns_zone_key = "blob_dns"
    dns_zone_group_name  = "blob-dns-zone-group"
    tags = {
      Service     = "PrivateLink"
      Environment = "Production"
    }
  }
}

# 8. Windows VMs Dictionary (Workload in Spoke Subnet, Standard_B2ats_v2)
windows_vms = {
  "spoke_vm01" = {
    name                 = "vm-spoke-win01"
    resource_group_name  = "rg-hubspoke-storage-prod"
    location             = "centralindia"
    virtual_network_name = "vnet-spoke"
    subnet_name          = "snet-spoke-workload"
    vm_size              = "Standard_B2ats_v2" # Standard B2ats v2 AMD burstable VM
    admin_username       = "azureuser"
    admin_password       = "Arjunmishra@12345" # Generates secure random password
    enable_public_ip     = true                # Allows RDP access for testing
    allowed_rdp_cidr     = "*"                 # Restrict to your client IP in enterprise production
    os_disk = {
      caching              = "ReadWrite"
      storage_account_type = "StandardSSD_LRS"
    }
    image = {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = "2022-datacenter-azure-edition"
      version   = "latest"
    }
    tags = {
      Role        = "WorkloadVM"
      Environment = "Production"
    }
  }
}

