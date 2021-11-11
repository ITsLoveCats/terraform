variable "resource_group" {
  type = object({
    name     = string
    location = string
  })
  default = {
    location = "southcentralus"
    name     = "1-dffaf016-playground-sandbox"
  }
}

module "virtual_network" {
  source              = "./modules/virtual_network"
  resource_group_name = var.resource_group.name
}

module "linux_virtual_machine" {
  source = "./modules/linux_virtual_machine"

  resource_group_name = var.resource_group.name

  # deploy on backend subnet
  subnet_id = module.virtual_network.subnet_be_id
}

module "application_gateway" {
  source = "./modules/application_gateway"

  resource_group_name = var.resource_group.name

  virtual_network_name = module.virtual_network.virtual_network_name

  # deploy on frontend subnet
  subnet_fe_id = module.virtual_network.subnet_fe_id

  virtual_machine_ip_1 = module.linux_virtual_machine.virtual_machine_ip_1
  virtual_machine_ip_2 = module.linux_virtual_machine.virtual_machine_ip_2
  virtual_machine_ip_3 = module.linux_virtual_machine.virtual_machine_ip_3

}

module "bastion_host" {
  source = "./modules/bastion_host"

  resource_group_name = var.resource_group.name

  virtual_network_name = module.virtual_network.virtual_network_name

  vnet_depends_on = module.virtual_network.vnet_depends_on
}

provider "azurerm" {
  skip_provider_registration = "true"
  features {}
}

