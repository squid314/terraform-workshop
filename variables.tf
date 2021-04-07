variable "resource-group-name" {
  description = "name of the resource group where we will put everything"
  default = "example-poc-rg"
  type = string

  validation {
    condition = can(regex("^[-a-zA-Z]*$", var.resource-group-name))
    error_message = "Resource Group name can only container letters and dashes."
  }
}

// vi: set ts=2 sts=2 sw=2 et ft=tf fdm=indent :
