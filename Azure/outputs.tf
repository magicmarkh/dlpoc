output "resource_group_name" {
  value = azurerm_resource_group.rg_1.name
}

output "win_conn_public_ip" {
  value = azurerm_windows_virtual_machine.az-win-conn01.public_ip_address
}
output "lin_conn_public_ip"{
    value = azurerm_linux_virtual_machine.dpa-ssh-conn01.public_ip_address
}

output "tls_private_key" {
  value     = tls_private_key.az_ssh_key.private_key_pem
  sensitive = true
}

output "dc01_password" {
  value     = azurerm_windows_virtual_machine.dc01.admin_password
  sensitive = true
}

output "wintgt01_password"{
  value = azurerm_windows_virtual_machine.wintgt01.admin_password
  sensitive = true
}

output "win_conn_password"{
  value = azurerm_windows_virtual_machine.az-win-conn01.admin_password
  sensitive = true
}