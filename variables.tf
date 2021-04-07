variable "resource-prefix" {
  description = "Prefix to attach to all resources to prevent naming collisions (used in some cases for DNS parts, so make sure it's valid)"
  default = "example-poc"
  type = string
}

variable "vnet-space"   { default = "10.22.0.0/16" }
variable "subnet-space" { default = "10.22.0.0/24" }

// vi: set ts=2 sts=2 sw=2 et ft=tf fdm=indent :
