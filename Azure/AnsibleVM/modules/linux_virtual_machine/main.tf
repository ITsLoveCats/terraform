provider "azurerm" {
  skip_provider_registration = "true"
  features {}
}

variable "resource_group_name" {}
variable "subnet_id" {}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
    for_each =              toset(var.vm_name)
    name                         = "${each.value}-myPublicIP"
    location                     = var.location
    resource_group_name          = var.resource_group_name
    allocation_method            = "Static"
    sku = "Standard"

    tags = {
        environment = "Terraform Demo"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "myNetworkSecurityGroup"
    location            = var.location
    resource_group_name = var.resource_group_name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "Terraform Demo"
    }
}

# Create network interface with Public IP 
resource "azurerm_network_interface" "nic" {
  for_each            = toset(var.vm_name)
  name                = "${each.value}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.myterraformpublicip[each.value].id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
    for_each = toset(var.vm_name)
    network_interface_id      = azurerm_network_interface.nic[each.value].id
    network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}

# az vm image list --output table 
resource "azurerm_linux_virtual_machine" "vm" {
  for_each            = toset(var.vm_name)
  name                = each.value
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = "Standard_F2"
  admin_username      = "azureuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.nic[each.key].id
  ]
  disable_password_authentication = false

  custom_data = base64encode(file("${path.module}/cloud-init-ansible.txt"))

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.example_ssh.public_key_openssh
  }
}

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
output "tls_private_key" {
  value     = tls_private_key.example_ssh.private_key_pem
  sensitive = true
}

output "pip_0" {
  value = azurerm_public_ip.myterraformpublicip["LinuxVM1"].ip_address
}

output "pip_1" {
  value = azurerm_public_ip.myterraformpublicip["LinuxVM2"].ip_address
}

output "private_ip" {
  value = toset([
    for private_ip in azurerm_network_interface.nic : private_ip.private_ip_address
  ])
}

