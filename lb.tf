resource "azurerm_public_ip" "lb-app-public-ip" {
  name = "${var.resource-prefix}-lb-app-public-ip"
  resource_group_name = azurerm_resource_group.rg-main.name
  location            = azurerm_resource_group.rg-main.location

  allocation_method = "Static"
  sku = "Standard"
  domain_name_label = "${var.resource-prefix}-lb-app"
}

resource "azurerm_lb" "lb-app" {
  name = "${var.resource-prefix}-lb-app"
  resource_group_name = azurerm_resource_group.rg-main.name
  location            = azurerm_resource_group.rg-main.location

  sku = "Standard"
  frontend_ip_configuration {
    name = "primary"
    public_ip_address_id = azurerm_public_ip.lb-app-public-ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "lb-app-backend-pool" {
  name = "${var.resource-prefix}-lb-app-backend-pool"
  resource_group_name = azurerm_resource_group.rg-main.name
  loadbalancer_id = azurerm_lb.lb-app.id
}

resource "azurerm_network_interface_backend_address_pool_association" "inst-app-nic-lb-app-backend-pool" {
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb-app-backend-pool.id
  network_interface_id = azurerm_network_interface.inst-app-nic.id
  ip_configuration_name = azurerm_network_interface.inst-app-nic.ip_configuration[0].name
}

resource "azurerm_lb_rule" "lb-app-rule" {
  name = "${var.resource-prefix}-lb-app-rule"
  resource_group_name = azurerm_resource_group.rg-main.name
  loadbalancer_id = azurerm_lb.lb-app.id

  protocol = "Tcp"
  frontend_port = 80
  frontend_ip_configuration_name = azurerm_lb.lb-app.frontend_ip_configuration[0].name
  backend_port = 8000
}

resource "azurerm_lb_probe" "lb-app-probe" {
  name = "${var.resource-prefix}-lb-app-probe"
  resource_group_name = azurerm_resource_group.rg-main.name
  loadbalancer_id = azurerm_lb.lb-app.id

  port = 8000
  protocol = "Http"
  request_path = "/health"
}

// vi: set ts=2 sts=2 sw=2 et ft=tf fdm=indent :
