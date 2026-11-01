# ==============================================================================
# SECURE RANDOM ADMIN PASSWORD FOR WINDOWS VM
# ==============================================================================
resource "random_password" "admin_password" {
  for_each = {
    for k, v in var.windows_vms : k => v
    if v.admin_password == null
  }

  length           = 16
  special          = true
  override_special = "!@#$%&*()-_=+[]:?"
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
}

# ==============================================================================
# PUBLIC IP (OPTIONAL, FOR RDP ACCESS / TESTING)
# ==============================================================================
resource "azurerm_public_ip" "pip" {
  for_each = {
    for k, v in var.windows_vms : k => v
    if coalesce(v.enable_public_ip, true)
  }

  name                = "pip-${each.value.name}"
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = each.value.tags
}

# ==============================================================================
# NETWORK SECURITY GROUP & RDP RULES
# ==============================================================================
resource "azurerm_network_security_group" "nsg" {
  for_each            = var.windows_vms
  name                = "nsg-${each.value.name}"
  resource_group_name = each.value.resource_group_name
  location            = each.value.location

  security_rule {
    name                       = "Allow-RDP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = coalesce(each.value.allowed_rdp_cidr, "*")
    destination_address_prefix = "*"
  }

  tags = each.value.tags
}

# ==============================================================================
# NETWORK INTERFACE (IN SPOKE WORKLOAD SUBNET)
# ==============================================================================
resource "azurerm_network_interface" "nic" {
  for_each            = var.windows_vms
  name                = "nic-${each.value.name}"
  resource_group_name = each.value.resource_group_name
  location            = each.value.location

  ip_configuration {
    name                          = "ipconfig-primary"
    subnet_id                     = var.subnet_ids_by_name[each.value.subnet_name]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = coalesce(each.value.enable_public_ip, true) ? azurerm_public_ip.pip[each.key].id : null
  }

  tags = each.value.tags
}

resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  for_each                  = var.windows_vms
  network_interface_id      = azurerm_network_interface.nic[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}

# ==============================================================================
# WINDOWS VIRTUAL MACHINE (STANDARD_B2ATS_V2 WORKLOAD IN SPOKE)
# ==============================================================================
resource "azurerm_windows_virtual_machine" "vm" {
  for_each = var.windows_vms

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  size                = coalesce(each.value.vm_size, "Standard_B2ats_v2")
  admin_username      = coalesce(each.value.admin_username, "azureuser")
  admin_password = (
    each.value.admin_password != null
    ? each.value.admin_password
    : random_password.admin_password[each.key].result
  )

  network_interface_ids = [
    azurerm_network_interface.nic[each.key].id
  ]

  os_disk {
    caching              = coalesce(try(each.value.os_disk.caching, null), "ReadWrite")
    storage_account_type = coalesce(try(each.value.os_disk.storage_account_type, null), "StandardSSD_LRS")
  }

  source_image_reference {
    publisher = coalesce(try(each.value.image.publisher, null), "MicrosoftWindowsServer")
    offer     = coalesce(try(each.value.image.offer, null), "WindowsServer")
    sku       = coalesce(try(each.value.image.sku, null), "2022-datacenter-azure-edition")
    version   = coalesce(try(each.value.image.version, null), "latest")
  }

  tags = each.value.tags

  depends_on = [
    azurerm_network_interface_security_group_association.nic_nsg
  ]
}

