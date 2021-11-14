provider "azurerm" {
  skip_provider_registration = "true"
  features {}
}

variable "subnet_id" {}
variable "route_table_id" {}

resource "azurerm_subnet_route_table_association" "this" {
  subnet_id      = var.subnet_id
  route_table_id = var.route_table_id
}
