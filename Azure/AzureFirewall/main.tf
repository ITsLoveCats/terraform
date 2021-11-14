variable "resource_group" {
  type = object({
    name     = string
    location = string
  })
  default = {
    location = "westus"
    name     = "1-bf8ae735-playground-sandbox"
  }
}

module "virtual_network" {
  source              = "./modules/virtual_network"
  resource_group_name = var.resource_group.name
}

module "window_virtual_machine" {
  source = "./modules/windows_virtual_machine"

  resource_group_name = var.resource_group.name

  subnet_id = module.virtual_network.vm_subnet_id
}

module "bastion_host" {
  source = "./modules/bastion_host"

  resource_group_name = var.resource_group.name

  virtual_network_name = module.virtual_network.virtual_network_name
}

module "route_table" {
  source = "./modules/route_table"

  resource_group_name = var.resource_group.name

  firewall_private_ip_address = module.firewall.firewall_private_ip_address
}

module "firewall" {
  source = "./modules/firewall"

  resource_group_name = var.resource_group.name

  firewall_subnet_id = module.virtual_network.firewall_subnet_id
  vm1_private_ip     = module.window_virtual_machine.vm1_private_ip
}

module "subnet_route_table_association" {
  source         = "./modules/subnet_route_table_association"
  subnet_id      = module.virtual_network.vm_subnet_id
  route_table_id = module.route_table.route_table_id
}

provider "azurerm" {
  skip_provider_registration = "true"
  features {}
}

output "virtual_network_id" {
  value = module.virtual_network.virtual_network_id
}

output "azure_firewall_public_ip" {
  value = module.firewall.firewall_public_ip_address
}