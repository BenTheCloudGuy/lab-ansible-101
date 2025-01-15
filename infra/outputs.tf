output "resource_group_name" {
  value = data.azurerm_resource_group.rg.name
}

output "vnet_name" {
  value = azurerm_virtual_network.vnet.name
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "bastion_name" {
  value = azurerm_bastion_host.bastion.name
}

output "bastion_public_ip" {
  value = azurerm_public_ip.bastion_public_ip.ip_address
}

output "keyvault_name" {
  value = azurerm_key_vault.kv.name
}

output "linuxVMName" {
  value = azurerm_linux_virtual_machine.linux_vm.name
}

output "LinuxVMAdminUsername" {
  value = azurerm_linux_virtual_machine.linux_vm.admin_username
}

output "LinuxVMIPAddress" {
  value = azurerm_linux_virtual_machine.linux_vm.private_ip_address
}

output "WindowsVMNames" {
  value = values(azurerm_windows_virtual_machine.windows_vm)[*].name
}

output "WindowsVMAdminUsernames" {
  value = values(azurerm_windows_virtual_machine.windows_vm)[*].admin_username
}

output "WindowsVMIPAddresses" {
  value = values(azurerm_windows_virtual_machine.windows_vm)[*].private_ip_address
}