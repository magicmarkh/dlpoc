output "resource_group_name" {
  value = azurerm_resource_group.rg_1.name
}

output "win_conn_public_ip" {
  value = azurerm_windows_virtual_machine.win-conn01.public_ip_address
}

output "lin_conn_public_ip"{
    value = azurerm_linux_virtual_machine.lin-conn01.public_ip_address
}

output "dc01_password" {
  value     = azurerm_windows_virtual_machine.dc01.admin_password
  sensitive = true
}

output "wintgt01_password"{
  value = azurerm_windows_virtual_machine.win-tgt01.admin_password
  sensitive = true
}

output "win_conn_password"{
  value = azurerm_windows_virtual_machine.win-conn01.admin_password
  sensitive = true
}