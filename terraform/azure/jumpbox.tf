resource "azurerm_public_ip" "jumpbox" {
  name                = "${local.name}-jumpbox-publicip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  domain_name_label   = "${local.name}-ssh"
}

resource "azurerm_subnet" "jumpbox" {
  name                 = "${local.name}-jumpbox-sub"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.22.0/30"]
}

resource "azurerm_network_interface" "jumpbox" {
  name                = "${local.name}-jumpbox-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "IPConfiguration"
    subnet_id                     = azurerm_subnet.jumpbox.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.22.22"
    public_ip_address_id          = azurerm_public_ip.jumpbox.id
  }
}

resource "azurerm_network_security_group" "jumpbox" {
  name                = "${local.name}-jumpbox-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_network_security_rule" "ssh" {
  name                        = "sshIn"
  network_security_group_name = azurerm_network_security_group.jumpbox.name
  resource_group_name         = azurerm_resource_group.main.name
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}


resource "azurerm_network_interface_security_group_association" "jumpbox" {
  network_interface_id      = azurerm_network_interface.jumpbox.id
  network_security_group_id = azurerm_network_security_group.jumpbox.id
}

resource "azurerm_linux_virtual_machine" "jumpbox" {
  name                  = "${local.name}-jumpbox-vm"
  computer_name         = "jumpbox"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  size                  = var.jumpbox_settings.size
  admin_username        = var.ansible_user
  admin_ssh_key {
    username   = var.ansible_user
    public_key = file(var.ansible_user_key)
  }

  custom_data           = data.cloudinit_config.jumpbox.rendered

  network_interface_ids = [
    azurerm_network_interface.jumpbox.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.jumpbox_settings.publisher
    offer     = var.jumpbox_settings.offer
    sku       = var.jumpbox_settings.sku
    version   = var.jumpbox_settings.version
  }

  identity {
    type = "SystemAssigned"
  }
}
