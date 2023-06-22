resource "azurerm_public_ip" "main-lb" {
  name                = "${local.name}-lb-publicip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  domain_name_label   = local.name
}

resource "azurerm_lb" "main" {
  name                = "${local.name}-lb"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  frontend_ip_configuration {
    name                 = "publicIPAddress"
    public_ip_address_id = azurerm_public_ip.main-lb.id
  }
}

resource "azurerm_lb_backend_address_pool" "main" {
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.main.id
  name                = "${local.name}-lb-BackEndAddressPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "pmg1" {
  network_interface_id    = azurerm_network_interface.pmg1.id
  ip_configuration_name   = "static-pmg1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
}

resource "azurerm_network_interface_backend_address_pool_association" "pmg2" {
  network_interface_id    = azurerm_network_interface.pmg.id
  ip_configuration_name   = "static-pmg2"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
}

resource "azurerm_network_interface_backend_address_pool_association" "pmg3" {
  network_interface_id    = azurerm_network_interface.pmg3.id
  ip_configuration_name   = "static-pmg3"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
}

resource "azurerm_lb_probe" "smtp_in" {
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.main.id
  name                = "smtp_in"
  port                = 25
  interval_in_seconds = 15
  number_of_probes    = 4
}

resource "azurerm_lb_probe" "smtp_out" {
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.main.id
  name                = "smtp_out"
  port                = 26
  interval_in_seconds = 15
  number_of_probes    = 4
}

resource "azurerm_lb_probe" "http" {
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.main.id
  name                = "http"
  port                = 80
  interval_in_seconds = 15
  number_of_probes    = 4
}

resource "azurerm_lb_probe" "https" {
  resource_group_name = azurerm_resource_group.main.name
  loadbalancer_id     = azurerm_lb.main.id
  name                = "https"
  port                = 443
  interval_in_seconds = 15
  number_of_probes    = 4
}

resource "azurerm_lb_rule" "smtp_in" {
  resource_group_name            = azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.main.id
  name                           = "smtp_in"
  protocol                       = "Tcp"
  frontend_port                  = 25
  backend_port                   = 25
  frontend_ip_configuration_name = "publicIPAddress"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.main.id
  probe_id                       = azurerm_lb_probe.smtp_in.id
  idle_timeout_in_minutes        = 30
}

resource "azurerm_lb_rule" "smtp_out" {
  resource_group_name            = azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.main.id
  name                           = "smtp_out"
  protocol                       = "Tcp"
  frontend_port                  = 26
  backend_port                   = 26
  frontend_ip_configuration_name = "publicIPAddress"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.main.id
  probe_id                       = azurerm_lb_probe.smtp_out.id
  idle_timeout_in_minutes        = 30
}

resource "azurerm_lb_rule" "http" {
  resource_group_name            = azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.main.id
  name                           = "http"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "publicIPAddress"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.main.id
  probe_id                       = azurerm_lb_probe.http.id
  idle_timeout_in_minutes        = 30
}

resource "azurerm_lb_rule" "https" {
  resource_group_name            = azurerm_resource_group.main.name
  loadbalancer_id                = azurerm_lb.main.id
  name                           = "https"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "publicIPAddress"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.main.id
  probe_id                       = azurerm_lb_probe.https.id
  idle_timeout_in_minutes        = 30
}
