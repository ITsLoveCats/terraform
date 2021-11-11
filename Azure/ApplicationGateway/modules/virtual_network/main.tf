provider "azurerm" {
  skip_provider_registration = "true"
  features {}
}

variable "resource_group_name" {}

resource "azurerm_virtual_network" "virtual_network" {
  resource_group_name = var.resource_group_name

  name          = var.name
  location      = var.location
  address_space = var.address_space

  tags = {
    environment = "Production"
  }
}

resource "azurerm_subnet" "subnet" {
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.virtual_network.name

  count            = length(var.subnets_name)
  name             = var.subnets_name[count.index]
  address_prefixes = [var.subnets_prefixes[count.index]]
}

output "virtual_network_id" {
  value = azurerm_virtual_network.virtual_network.id
}

output "virtual_network_name" {
  value = azurerm_virtual_network.virtual_network.name
}

output "subnet_fe_id" {
  value = azurerm_subnet.subnet[0].id
}

output "subnet_be_id" {
  value = azurerm_subnet.subnet[1].id
}

output "vnet_depends_on" {
  value = azurerm_subnet.subnet[1].id
}