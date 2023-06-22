resource "azurerm_subnet" "pmg" {
  name                 = "${local.name}-pmg-sub"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.25.0/27"]
}

resource "azurerm_network_interface" "pmg1" {
  name                = "${local.name}-pmg1-nic"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "static-pmg1"
    subnet_id                     = azurerm_subnet.pmg.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.25.11"
  }
}

resource "azurerm_network_interface" "pmg2" {
  name                = "${local.name}-pmg2-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "static-pmg2"
    subnet_id                     = azurerm_subnet.pmg.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.25.12"
  }
}

resource "azurerm_network_interface" "pmg3" {
  name                = "${local.name}-pmg3-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "static-pmg3"
    subnet_id                     = azurerm_subnet.pmg.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.25.13"
  }
}

resource "azurerm_availability_set" "pmg-avset" {
  name                         = "${local.name}-pmg-avset"
  location                     = azurerm_resource_group.main.location
  resource_group_name          = azurerm_resource_group.main.name
  managed                      = true
}

resource "azurerm_network_security_group" "pmg" {
  name                = "${local.name}-pmg-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_network_security_rule" "smtp_in" {
  name                        = "smtpIn"
  network_security_group_name = azurerm_network_security_group.pmg.name
  resource_group_name         = azurerm_resource_group.main.name
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "25"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "smtp_out" {
  name                        = "smtpIn"
  network_security_group_name = azurerm_network_security_group.mgr.name
  resource_group_name         = azurerm_resource_group.main.name
  priority                    = 310
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "26"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}


resource "azurerm_network_security_rule" "https" {
  name                        = "httpsIn"
  network_security_group_name = azurerm_network_security_group.mgr.name
  resource_group_name         = azurerm_resource_group.main.name
  priority                    = 320
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "http" {
  name                        = "httpIn"
  network_security_group_name = azurerm_network_security_group.mgr.name
  resource_group_name         = azurerm_resource_group.main.name
  priority                    = 330
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_interface_security_group_association" "pmg3" {
  network_interface_id      = azurerm_network_interface.pmg3.id
  network_security_group_id = azurerm_network_security_group.pmg.id
}

resource "azurerm_network_interface_security_group_association" "pmg2" {
  network_interface_id      = azurerm_network_interface.pmg2.id
  network_security_group_id = azurerm_network_security_group.pmg.id
}

resource "azurerm_network_interface_security_group_association" "pmg1" {
  network_interface_id      = azurerm_network_interface.pmg1.id
  network_security_group_id = azurerm_network_security_group.pmg.id
}

resource "azurerm_linux_virtual_machine" "pmg1" {
  name                     = "${local.name}-pmg1-vm"
  computer_name            = "azure-pmg1"
  location                 = azurerm_resource_group.main.location
  resource_group_name      = azurerm_resource_group.main.name
  size                     = var.pmg_settings.size
  availability_set_id      = azurerm_availability_set.pmg-avset.id
  admin_username           = var.ansible_user
  admin_password           = random_password.password.result
  admin_ssh_key {
    username   = var.ansible_user
    public_key = file(var.ansible_user_key)
  }
  custom_data              = data.cloudinit_config.pmg.rendered


  network_interface_ids = [
    azurerm_network_interface.pmg1.id,
  ]

  source_image_reference {
    id=data.azurerm_image.pmg-image.id
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_linux_virtual_machine" "pmg2" {
  name                     = "${local.name}-pmg2-vm"
  computer_name            = "azure-pmg2"
  location                 = azurerm_resource_group.main.location
  resource_group_name      = azurerm_resource_group.main.name
  size                     = var.pmg_settings.size
  availability_set_id      = azurerm_availability_set.pmg-avset.id
  admin_username           = var.ansible_user
  admin_password           = random_password.password.result
  admin_ssh_key {
    username   = var.ansible_user
    public_key = file(var.ansible_user_key)
  }
  custom_data              = data.cloudinit_config.pmg.rendered

  network_interface_ids = [
    azurerm_network_interface.pmg2.id
  ]

  source_image_reference {
    id=data.azurerm_image.pmg-image.id
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_linux_virtual_machine" "pmg3" {
  name                     = "${local.name}-pmg3-vm"
  computer_name            = "azure-pmg3"
  location                 = azurerm_resource_group.main.location
  resource_group_name      = azurerm_resource_group.main.name
  size                     = var.pmg_settings.size
  availability_set_id      = azurerm_availability_set.pmg-avset.id
  admin_username           = var.ansible_user
  admin_password           = random_password.password.result
  admin_ssh_key {
    username   = var.ansible_user
    public_key = file(var.ansible_user_key)
  }
  custom_data              = data.cloudinit_config.pmg.rendered

  network_interface_ids = [
    azurerm_network_interface.pmg3.id
  ]

  source_image_reference {
    id=data.azurerm_image.pmg-image.id
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_managed_disk" "datadisk1" {
  name                 = "${local.name}-pmg1-datadisk"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 4
}

resource "azurerm_virtual_machine_data_disk_attachment" "datadisk1" {
  managed_disk_id    = azurerm_managed_disk.datadisk1.id
  virtual_machine_id = azurerm_linux_virtual_machine.pmg1.id
  lun                = "10"
  caching            = "ReadWrite"
}

resource "azurerm_managed_disk" "datadisk2" {
  name                 = "${local.name}-pmg2-datadisk"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 4
}

resource "azurerm_virtual_machine_data_disk_attachment" "datadisk2" {
  managed_disk_id    = azurerm_managed_disk.datadisk2.id
  virtual_machine_id = azurerm_linux_virtual_machine.pmg2.id
  lun                = "10"
  caching            = "ReadWrite"
}

resource "azurerm_managed_disk" "datadisk3" {
  name                 = "${local.name}-pmg3-datadisk"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 4
}

resource "azurerm_virtual_machine_data_disk_attachment" "datadisk3" {
  managed_disk_id    = azurerm_managed_disk.datadisk3.id
  virtual_machine_id = azurerm_linux_virtual_machine.pmg3.id
  lun                = "10"
  caching            = "ReadWrite"
}
