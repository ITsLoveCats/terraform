variable "resource_group" {
  type = object({
    name     = string
    location = string
  })
  default = {
    location = "eastus"
    name     = "1-66d10aca-playground-sandbox"
  }
}

module "virtual_network" {
  source              = "./modules/virtual_network"
  resource_group_name = var.resource_group.name
}

module "nat_gateway" {
  source              = "./modules/nat_gateway"
  resource_group_name = var.resource_group.name
}

module "window_virtual_machine" {
  source = "./modules/windows_virtual_machine"

  resource_group_name = var.resource_group.name

  subnet_id = module.virtual_network.subnet_id
}

module "bastion_host" {
  source = "./modules/bastion_host"

  resource_group_name = var.resource_group.name

  virtual_network_name = module.virtual_network.virtual_network_name
}

provider "azurerm" {
  skip_provider_registration = "true"
  features {}
}

resource "azurerm_subnet_nat_gateway_association" "this" {
  subnet_id      = module.virtual_network.subnet_id
  nat_gateway_id = module.nat_gateway.natgw_id
}

output "virtual_network_id" {
  value = module.virtual_network.virtual_network_id
}

output "nat_gateway_pip" {
  value = module.nat_gateway.natpip
}