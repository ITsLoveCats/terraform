provider "azurerm" {
  skip_provider_registration = "true"
  features {}
}

variable "resource_group_name" {}
variable "virtual_network_name" {}
variable "depends_on_module_virtual_network0" {}
variable "depends_on_module_virtual_network1" {}

resource "azurerm_subnet" "bastion_subnet" {
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name

  name             = "AzureBastionSubnet"
  address_prefixes = ["10.0.3.224/27"]

  # Since I am creating dedicated Bastion Subnet here,
  # And there are creating other subnet concurrently outside this module,
  # So, this module need to be the last order of execution.
  depends_on = [
    var.depends_on_module_virtual_network0,
    var.depends_on_module_virtual_network1
  ]
}

resource "azurerm_public_ip" "bastion_pip" {
  location            = "eastus"
  resource_group_name = var.resource_group_name

  name              = "bastionpip"
  allocation_method = "Static"
  sku               = "Standard"
}

resource "azurerm_bastion_host" "bastion_host" {
  location            = "eastus"
  resource_group_name = var.resource_group_name

  name = "bastionhost"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.bastion_pip.id
  }
}

