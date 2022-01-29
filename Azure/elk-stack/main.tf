# az login
# az group list | jq '.[0].name'

# Configure a Linux VM with infrastructure in Azure using Terraform
# https://docs.microsoft.com/en-us/azure/developer/terraform/create-linux-virtual-machine-with-infrastructure

variable "resource_group" {
  type = object({
    name     = string
    location = string
  })
  default = {
    location = "eastus"
    name     = "1-e63bad30-playground-sandbox"
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

  subnet_id = module.virtual_network.subnet_id_0
}

module "linux_virtual_machine" {
  source = "./modules/linux_virtual_machine"

  resource_group_name = var.resource_group.name

  subnet_id = module.virtual_network.subnet_id_1
}

module "bastion_host" {
  source = "./modules/bastion_host"

  resource_group_name = var.resource_group.name

  virtual_network_name = module.virtual_network.virtual_network_name

  depends_on_module_virtual_network0 = module.virtual_network.subnet_id_0
  depends_on_module_virtual_network1 = module.virtual_network.subnet_id_1

}

provider "azurerm" {
  skip_provider_registration = "true"
  features {}
}

resource "azurerm_subnet_nat_gateway_association" "this0" {
  subnet_id      = module.virtual_network.subnet_id_0
  nat_gateway_id = module.nat_gateway.natgw_id
}

resource "azurerm_subnet_nat_gateway_association" "this1" {
  subnet_id      = module.virtual_network.subnet_id_1
  nat_gateway_id = module.nat_gateway.natgw_id
}


