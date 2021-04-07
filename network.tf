resource "azurerm_virtual_network" "vnet-main" {
  name = var.vnet-name
  resource_group_name = var.resource-group-name
  location            = "West US 2"
  address_space = [var.vnet-space]
}

resource "azurerm_subnet" "subnet-main" {
  name = var.subnet-name
  resource_group_name = var.resource-group-name
  virtual_network_name = var.vnet-name
  address_prefixes = [var.subnet-space]
}

// vi: set ts=2 sts=2 sw=2 et ft=tf fdm=indent :
