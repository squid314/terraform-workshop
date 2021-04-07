resource "azurerm_virtual_network" "vnet-main" {
  name = "${var.resource-prefix}-vnet-main"
  resource_group_name = azurerm_resource_group.rg-main.name
  location            = azurerm_resource_group.rg-main.location
  address_space = [var.vnet-space]
}

resource "azurerm_subnet" "subnet-main" {
  name = "${var.resource-prefix}-subnet-main"
  resource_group_name = azurerm_resource_group.rg-main.name
  virtual_network_name = azurerm_virtual_network.vnet-main.name
  address_prefixes = [var.subnet-space]
}

// vi: set ts=2 sts=2 sw=2 et ft=tf fdm=indent :
