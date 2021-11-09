variable "resource_group" {
  type = object({
    name     = string
    location = string
  })
  default = {
    location = "westus"
    name     = "1-88749b9f-playground-sandbox"
  }
}

module "virtual_network" {
  source              = "./modules/virtual_network"
  resource_group_name = var.resource_group.name
}

module "window_virtual_machine" {
  source = "./modules/windows_virtual_machine"

  resource_group_name = var.resource_group.name

  subnet_id            = module.virtual_network.subnet_id
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

output "virtual_network_id" {
  value = module.virtual_network.virtual_network_id
}