provider "azurerm" {
  skip_provider_registration = "true"
  features {}
}

variable "resource_group_name" {}

resource "azurerm_public_ip" "natpip" {
  location            = var.location
  resource_group_name = var.resource_group_name

  name              = "natpip0"
  allocation_method = "Static"
  sku               = "Standard"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_nat_gateway" "natgw" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Standard"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_nat_gateway_public_ip_association" "this" {
  nat_gateway_id       = azurerm_nat_gateway.natgw.id
  public_ip_address_id = azurerm_public_ip.natpip.id
}

output "natpip" {
  value = azurerm_public_ip.natpip.ip_address
}

output "natgw_id" {
  value = azurerm_nat_gateway.natgw.id
}