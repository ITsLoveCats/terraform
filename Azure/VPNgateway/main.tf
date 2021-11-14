variable "resource_group" {
  type = object({
    name     = string
    location = string
  })
  default = {
    location = "southcentralus"
    name     = "1-dfec72cd-playground-sandbox"
  }
}

module "virtual_network" {
  source              = "./modules/virtual_network"
  resource_group_name = var.resource_group.name
}

module "virtual_network_gateway" {
  source              = "./modules/virtual_network_gateway"
  resource_group_name = var.resource_group.name
  subnet_id           = module.virtual_network.subnet_id
}

provider "azurerm" {
  skip_provider_registration = "true"
  features {}
}

output "virtual_network_id" {
  value = module.virtual_network.virtual_network_id
}

