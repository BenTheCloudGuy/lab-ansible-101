## Fetch ResourceGroup created with Ansible
data "azurerm_resource_group" "rg" {
  name = var.rgName
}

# Fetch Azure Client Configuration
data "azurerm_client_config" "current" {}

## Deploy Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.rgName}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "vm_subnet" {
  name                 = var.vm_subnet_name
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create NSG for VM Subnet
resource "azurerm_network_security_group" "vm_nsg" {
  name                = "${var.vm_subnet_name}-nsg"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = data.azurerm_resource_group.rg.tags
}

# Create NSG Rule to allow traffic from Bastion Subnet
resource "azurerm_network_security_rule" "allow_bastion_to_vm" {
  name                        = "AllowBastionToVM"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = azurerm_subnet.bastion_subnet.address_prefixes[0]
  destination_address_prefix  = azurerm_subnet.vm_subnet.address_prefixes[0]
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.vm_nsg.name
}

# Associate NSG with VM Subnet
resource "azurerm_subnet_network_security_group_association" "vm_subnet_nsg_association" {
  subnet_id                 = azurerm_subnet.vm_subnet.id
  network_security_group_id = azurerm_network_security_group.vm_nsg.id
}

## Deploy Bastion Services
resource "azurerm_public_ip" "bastion_public_ip" {
  name                = "bastionPublicIP"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "bastion" {
  name                = "${var.rgName}-bastion"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  tags                = data.azurerm_resource_group.rg.tags  
  sku                 = "Standard"
  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.bastion_public_ip.id
  }
}

# Deploy Key Vault
resource "azurerm_key_vault" "kv" {
  name                        = "${var.rgName}-kv"
  location                    = data.azurerm_resource_group.rg.location
  resource_group_name         = data.azurerm_resource_group.rg.name
  tags                        = data.azurerm_resource_group.rg.tags
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = false
  enable_rbac_authorization   = true
}

# Generate a random password
resource "random_password" "linux_vm_password" {
  length  = 16
  special = true
}

resource "random_password" "windows_vm_password" {
  length  = 16
  special = true
}

# Store the generated password in Key Vault as linuxVMSecret
resource "azurerm_key_vault_secret" "linux_vm_secret" {
  name         = "linuxVMSecret"
  value        = random_password.linux_vm_password.result
  key_vault_id = azurerm_key_vault.kv.id
}

resource "azurerm_key_vault_secret" "windows_vm_secret" {
  name         = "windowsVMSecret"
  value        = random_password.windows_vm_password.result
  key_vault_id = azurerm_key_vault.kv.id
}

# Create Network Interface for Ubuntu VM
resource "azurerm_network_interface" "linux_vm_nic" {
  name                = "linuxVMNic"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Retrieve the password from Key Vault
data "azurerm_key_vault_secret" "linux_vm_secret" {
  name         = azurerm_key_vault_secret.linux_vm_secret.name
  key_vault_id = azurerm_key_vault.kv.id
}

# Create Ubuntu VM
resource "azurerm_linux_virtual_machine" "linux_vm" {
  name                  = lower("${var.rgName}vm01")
  location              = data.azurerm_resource_group.rg.location
  resource_group_name   = data.azurerm_resource_group.rg.name
  tags                  = data.azurerm_resource_group.rg.tags
  network_interface_ids = [
    azurerm_network_interface.linux_vm_nic.id,
  ]
  disable_password_authentication = false
  size                            = "Standard_DS1_v2"
  admin_username                  = "adminuser"
  admin_password                  = data.azurerm_key_vault_secret.linux_vm_secret.value

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

# Retrieve the password from Key Vault for Windows VM
data "azurerm_key_vault_secret" "windows_vm_secret" {
  name         = azurerm_key_vault_secret.windows_vm_secret.name
  key_vault_id = azurerm_key_vault.kv.id
}
locals {
  windows_vms = {
    winvm01 = lower("${var.rgName}vm02")
    winvm02 = lower("${var.rgName}vm03")
  }
}

# Create Network Interfaces for Windows VMs
resource "azurerm_network_interface" "windows_vm_nic" {
  for_each            = local.windows_vms
  name                = "${each.value}-nic"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create Windows VMs
resource "azurerm_windows_virtual_machine" "windows_vm" {
  for_each            = local.windows_vms
  name                = "${each.value}"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  network_interface_ids = [
    azurerm_network_interface.windows_vm_nic[each.key].id,
  ]
  size                = "Standard_DS1_v2"
  admin_username      = "adminuser"
  admin_password      = data.azurerm_key_vault_secret.windows_vm_secret.value

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}