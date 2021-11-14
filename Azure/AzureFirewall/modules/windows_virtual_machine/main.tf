provider "azurerm" {
  skip_provider_registration = "true"
  features {}
}

variable "resource_group_name" {}
variable "subnet_id" {}

resource "azurerm_network_interface" "nic" {
  for_each            = toset(var.vm_name)
  name                = "${each.value}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_servers         = ["209.244.0.3", "209.244.0.4"]

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  for_each            = toset(var.vm_name)
  name                = each.value
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.nic[each.key].id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

output "vm1_private_ip" {
  value = azurerm_windows_virtual_machine.vm[element(var.vm_name, 0)].private_ip_address
}