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

// Security
resource "azurerm_network_security_group" "nsg-main" {
  name = "${var.resource-prefix}-nsg-main"
  resource_group_name = azurerm_resource_group.rg-main.name
  location            = azurerm_resource_group.rg-main.location
}

resource "azurerm_subnet_network_security_group_association" "subnet-main-nsg-main" {
  subnet_id = azurerm_subnet.subnet-main.id
  network_security_group_id = azurerm_network_security_group.nsg-main.id
}

resource "azurerm_application_security_group" "asg-bastion" {
  name = "${var.resource-prefix}-asg-bastion"
  resource_group_name = azurerm_resource_group.rg-main.name
  location            = azurerm_resource_group.rg-main.location
}

resource "azurerm_network_security_rule" "nsg-main-rule-inbound-ssh-asg-bastion" {
  name = "${var.resource-prefix}-nsg-main-rule-inbound-ssh-asg-bastion"
  resource_group_name = azurerm_resource_group.rg-main.name
  network_security_group_name = azurerm_network_security_group.nsg-main.id

  access = "Allow"
  direction = "Inbound"
  protocol = "Tcp"
  source_address_prefix = "*"
  source_port_range = "*"
  destination_application_security_group_ids = [azurerm_application_security_group.asg-bastion.id]
  destination_port_ranges = ["22"]
  priority = 1000
}

resource "azurerm_application_security_group" "asg-app" {
  name = "${var.resource-prefix}-asg-bastion"
  resource_group_name = azurerm_resource_group.rg-main.name
  location            = azurerm_resource_group.rg-main.location
}

resource "azurerm_network_security_rule" "nsg-main-rule-inbound-newapp-asg-app" {
  name = "${var.resource-prefix}-nsg-main-rule-inbound-newapp-asg-app"
  resource_group_name = azurerm_resource_group.rg-main.name
  network_security_group_name = azurerm_network_security_group.nsg-main.id

  access = "Allow"
  direction = "Inbound"
  protocol = "Tcp"
  source_address_prefix = "*"
  source_port_range = "*"
  destination_application_security_group_ids = [azurerm_application_security_group.asg-app.id]
  destination_port_ranges = ["8000"]
  priority = 1001
}

// vi: set ts=2 sts=2 sw=2 et ft=tf fdm=indent :
