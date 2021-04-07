variable "resource-group-name" {
  description = "name of the resource group where we will put everything"
  default = "example-poc-rg"
  type = string

  validation {
    condition = can(regex("^[-a-zA-Z]*$", var.resource-group-name))
    error_message = "Resource Group name can only container letters and dashes."
  }
}

variable "vnet-name"    { default = "example-poc-vnet-main" }
variable "subnet-name"  { default = "example-poc-subnet-main" }
variable "vnet-space"   { default = "10.22.0.0/16" }
variable "subnet-space" { default = "10.22.0.0/24" }

// vi: set ts=2 sts=2 sw=2 et ft=tf fdm=indent :
