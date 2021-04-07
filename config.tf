terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">=2.46.0, <3.0.0"
    }
  }
}

provider "azurerm" {
  features {
  }

  // Note: here is where login credentials may be placed
  //subscription_id = ""
  //client_id       = ""
  //client_secret   = ""
  //tenant_id       = ""
}

// vi: set ts=2 sts=2 sw=2 et ft=tf fdm=indent :
