#create resource group
resource "azurerm_resource_group" "rg_1" {
  name = "rg_1"
  location = var.datacenter_location
}

#create virtual network
resource "azurerm_virtual_network" "vn_1" {
  name = "az01-vnet"
  address_space = [ "10.10.0.0/16" ]
  location = var.datacenter_location
  resource_group_name = azurerm_resource_group.rg_1.name
}

#create subnet
resource "azurerm_subnet" "sn_1" {
  name = "pineapple-subnet"
  resource_group_name = azurerm_resource_group.rg_1.name
  virtual_network_name = azurerm_virtual_network.vn_1.name
  address_prefixes = [ "10.10.10.0/24" ]
}

#create Network Security Groups and Rules
resource "azurerm_network_security_group" "sg_ssh" {
  name = "sg_ssh"
  location = var.datacenter_location
  resource_group_name = azurerm_resource_group.rg_1.name

  security_rule {
    name                       = "SSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    destination_address_prefix = "*"
    source_address_prefixes = ["208.127.94.133","208.127.93.165","66.37.42.10","66.37.42.11","208.127.190.40","134.238.168.126","208.127.83.50","208.127.70.67","208.127.93.164"]
  } 
  security_rule {
    name                       = "Local_Access"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"     
    protocol                   = "*"
    destination_port_range     = "*"
    destination_address_prefix = "*"
    source_port_range          = "*"
    source_address_prefixes = ["10.10.10.0/24"]
  }
}

resource "azurerm_network_security_group" "sg_rdp" {
  name = "sg_rdp"
  location = var.datacenter_location
  resource_group_name = azurerm_resource_group.rg_1.name

  security_rule {
    name                       = "RDP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    destination_address_prefix = "*"
    source_address_prefixes = ["208.127.94.133","208.127.93.165","66.37.42.10","66.37.42.11","208.127.190.40","134.238.168.126","208.127.83.50","208.127.70.67","208.127.93.164"]
  } 
  security_rule {
    name                       = "Local_Access"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"     
    protocol                   = "*"
    destination_port_range     = "*"
    destination_address_prefix = "*"
    source_port_range          = "*"
    source_address_prefixes = ["10.10.10.0/24"]
  }
}

#create public IPs

resource "azurerm_public_ip" "ip_conn_win" {
  name = "ip_conn_win"
  location = var.datacenter_location
  resource_group_name = azurerm_resource_group.rg_1.name
  allocation_method = "Dynamic"
}

resource "azurerm_public_ip" "ip_conn_ssh" {
  name = "ip_conn_ssh"
  location = var.datacenter_location
  resource_group_name = azurerm_resource_group.rg_1.name
  allocation_method = "Dynamic"
}

#create NIC
resource "azurerm_network_interface" "dc01-nic" {
  name = "dc01-nic"
  location = var.datacenter_location
  resource_group_name = azurerm_resource_group.rg_1.name

  ip_configuration {
    name = "az-dc01-nic-config"
    subnet_id = azurerm_subnet.sn_1.id
    private_ip_address_allocation = "Static"
    private_ip_address = "10.10.10.5"
  }
}

resource "azurerm_network_interface" "wintgt01-nic" {
  name = "wintgt01-nic"
  location = var.datacenter_location
  resource_group_name = azurerm_resource_group.rg_1.name

  ip_configuration {
    name = "wintgt01-nic-config"
    subnet_id = azurerm_subnet.sn_1.id
    private_ip_address_allocation = "Static"
    private_ip_address = "10.10.10.10"
  }
}
resource "azurerm_network_interface" "win-conn-nic" {
  name = "win-conn-nic"
  location = var.datacenter_location
  resource_group_name = azurerm_resource_group.rg_1.name

  ip_configuration {
    name = "win-conn-nic-config"
    subnet_id = azurerm_subnet.sn_1.id
    private_ip_address_allocation = "Static"
    private_ip_address = "10.10.10.15"
    public_ip_address_id = azurerm_public_ip.ip_conn_win.id
  }
}

resource "azurerm_network_interface" "lin-conn-nic" {
  name = "lin-conn-nic"
  location = var.datacenter_location
  resource_group_name = azurerm_resource_group.rg_1.name

  ip_configuration {
    name = "lin-conn-nic-config"
    subnet_id = azurerm_subnet.sn_1.id
    private_ip_address_allocation = "Static"
    private_ip_address = "10.10.10.20"
    public_ip_address_id = azurerm_public_ip.ip_conn_ssh.id
  }
}

resource "azurerm_network_interface" "lintgt01-nic" {
  name = "lintgt01-nic"
  location = var.datacenter_location
  resource_group_name = azurerm_resource_group.rg_1.name

  ip_configuration {
    name = "lintgt01-nic-config"
    subnet_id = azurerm_subnet.sn_1.id
    private_ip_address_allocation = "Static"
    private_ip_address = "10.10.10.25"
  }
}


#connect security groups to nics
resource "azurerm_network_interface_security_group_association" "as_sg_dc01" {
  network_interface_id = azurerm_network_interface.dc01-nic.id
  network_security_group_id = azurerm_network_security_group.sg_rdp.id  
}


resource "azurerm_network_interface_security_group_association" "as_sg_wintgt01" {
  network_interface_id = azurerm_network_interface.wintgt01-nic.id
  network_security_group_id = azurerm_network_security_group.sg_rdp.id  
}

resource "azurerm_network_interface_security_group_association" "as_sg_win_conn" {
  network_interface_id = azurerm_network_interface.win-conn-nic.id
  network_security_group_id = azurerm_network_security_group.sg_rdp.id  
}

resource "azurerm_network_interface_security_group_association" "as_sg_linconn" {
  network_interface_id = azurerm_network_interface.lin-conn-nic.id
  network_security_group_id = azurerm_network_security_group.sg_ssh.id
}

resource "azurerm_network_interface_security_group_association" "as_sg_lintgt01" {
  network_interface_id = azurerm_network_interface.lintgt01-nic.id
  network_security_group_id = azurerm_network_security_group.sg_ssh.id
}



#create storage account for boot diagnostics
resource "azurerm_storage_account" "my_storage_account" {
  name                     = "diag${random_id.random_id.hex}"
  location                 = var.datacenter_location
  resource_group_name      = azurerm_resource_group.rg_1.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


# Create windows virtual machines
resource "azurerm_windows_virtual_machine" "dc01" {
  name                  = "dc01"
  admin_username        = "azureuser"
  admin_password        = random_password.password.result
  location              = var.datacenter_location
  resource_group_name   = azurerm_resource_group.rg_1.name
  network_interface_ids = [azurerm_network_interface.dc01-nic.id]
  size                  = "Standard_B1ms"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }
}


resource "azurerm_windows_virtual_machine" "wintgt01" {
  name                  = "wintgt01"
  admin_username        = "azureuser"
  admin_password        = random_password.password.result
  location              = var.datacenter_location
  resource_group_name   = azurerm_resource_group.rg_1.name
  network_interface_ids = [azurerm_network_interface.wintgt01-nic.id]
  size                  = "Standard_B1ms"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }
}


resource "azurerm_windows_virtual_machine" "az-win-conn01" {
  name                  = "az-win-conn01"
  admin_username        = "azureuser"
  admin_password        = random_password.password.result
  location              = var.datacenter_location
  resource_group_name   = azurerm_resource_group.rg_1.name
  network_interface_ids = [azurerm_network_interface.win-conn-nic.id]
  size                  = "Standard_F8s_v2"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.my_storage_account.primary_blob_endpoint
  }
}

#use terraform provider w/ Conjur Cloud to pull my dapuser key, and login to identity
#drop to shell and execute go code

#Create SSH Key for Linux VM's
resource "tls_private_key" "az_ssh_key"{
  algorithm = "RSA"
  rsa_bits = 4096
}
#Create Linux VM's
resource "azurerm_linux_virtual_machine" "dpa-ssh-conn01" {
  name = "az-dpa-ssh-conn01"
  location = var.datacenter_location
  resource_group_name = azurerm_resource_group.rg_1.name
  network_interface_ids = [azurerm_network_interface.lin-conn-nic.id]
  size = "Standard_B1ms"

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer = "0001-com-ubuntu-server-jammy"
    sku = "22_04-lts-gen2"
    version = "latest"
  }

  computer_name = "az-dpa-ssh-conn01"
  admin_username = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username = "azureuser"
    public_key = tls_private_key.az_ssh_key.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.my_storage_account.primary_blob_endpoint
  }
}

resource "azurerm_linux_virtual_machine" "lintgt01" {
  name = "lintgt01"
  location = var.datacenter_location
  resource_group_name = azurerm_resource_group.rg_1.name
  network_interface_ids = [azurerm_network_interface.lintgt01-nic.id]
  size = "Standard_B1s"

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer = "0001-com-ubuntu-server-jammy"
    sku = "22_04-lts-gen2"
    version = "latest"
  }

  computer_name = "lintgt01"
  admin_username = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username = "azureuser"
    public_key = tls_private_key.az_ssh_key.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.my_storage_account.primary_blob_endpoint
  }
}
# Generate random text 
resource "random_id" "random_id" {
  byte_length = 8
}

#generate random password
resource "random_password" "password" {
  length      = 20
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
  special     = true
}