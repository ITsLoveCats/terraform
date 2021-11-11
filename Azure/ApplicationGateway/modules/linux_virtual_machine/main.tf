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

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
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

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  custom_data = filebase64("${path.module}/${each.value}-cloud-init.txt")
}

output "virtual_machine_ip_1" {
  # value = azurerm_linux_virtual_machine.vm[0].private_ip_address
  value = azurerm_network_interface.nic[element(var.vm_name, 0)].private_ip_address
}

output "virtual_machine_ip_2" {
  # value = azurerm_linux_virtual_machine.vm[0].private_ip_address
  value = azurerm_network_interface.nic[element(var.vm_name, 1)].private_ip_address
}

output "virtual_machine_ip_3" {
  # value = azurerm_linux_virtual_machine.vm[0].private_ip_address
  value = azurerm_network_interface.nic[element(var.vm_name, 2)].private_ip_address
}

output "as_depend_on" {
  value = azurerm_linux_virtual_machine.vm[element(var.vm_name, length(var.vm_name) - 1)].id
}

output "vm_name" {
  value = var.vm_name
}