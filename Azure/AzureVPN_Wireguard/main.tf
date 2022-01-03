# az login
# az group list | jq -r '.[].location'
# az group list | jq -r '.[].name'

variable "resource_group" {
  type = object({
    name     = string
    location = string
  })
  default = {
    location = "eastus"
    name     = "1-b22abd8b-playground-sandbox"
  }
}

module "virtual_network" {
  source              = "./modules/virtual_network"
  resource_group_name = var.resource_group.name
}

module "linux_virtual_machine" {
  source = "./modules/linux_virtual_machine"

  resource_group_name = var.resource_group.name

  subnet_id = module.virtual_network.subnet_id
}

module "linux_virtual_client" {
  source = "./modules/linux_virtual_client"

  resource_group_name = var.resource_group.name

  subnet_id = module.virtual_network.subnet_id
}

module "bastion_host" {
  source = "./modules/bastion_host"

  resource_group_name = var.resource_group.name

  virtual_network_name = module.virtual_network.virtual_network_name

  # for dependency
  subnet_id = module.virtual_network.subnet_id
}

provider "azurerm" {
  skip_provider_registration = "true"
  features {}
}

output "virtual_network_id" {
  value = module.virtual_network.virtual_network_id
}