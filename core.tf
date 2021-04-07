resource "azurerm_resource_group" "rg-main" {
  name = "example-poc-rg"
  location = "West US 2"
}

// Note: if you wish to add to an existing resource group, you can use this and
// add "data." to every azurerm_resource_group reference.
//data "azurerm_resource_group" "rg-main" {
//  name = "example-poc-rg"
//}

// vi: set ts=2 sts=2 sw=2 et ft=tf fdm=indent :
