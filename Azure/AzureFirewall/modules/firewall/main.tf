provider "azurerm" {
  skip_provider_registration = "true"
  features {}
}

variable "resource_group_name" {}
variable "firewall_subnet_id" {}
variable "vm1_private_ip" {}

// ALREADY PROVISIONED AT VNET MODULE
# resource "azurerm_subnet" "example" {
#   name                 = "AzureFirewallSubnet"
#   resource_group_name  = azurerm_resource_group.example.name
#   virtual_network_name = azurerm_virtual_network.example.name
#   address_prefixes     = ["10.0.1.0/24"]
# }

resource "azurerm_public_ip" "this" {
  name                = "fewpip"
  location            = "eastus"
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "this" {
  name                = "Test-FW01"
  location            = "eastus"
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.firewall_subnet_id
    public_ip_address_id = azurerm_public_ip.this.id
  }
}

resource "azurerm_firewall_application_rule_collection" "example" {
  name                = "App-Colll01"
  azure_firewall_name = azurerm_firewall.this.name
  resource_group_name = var.resource_group_name
  priority            = 200
  action              = "Allow"

  rule {
    name = "Allow-Google"

    source_addresses = [
      "192.168.2.0/24"
    ]

    target_fqdns = [
      "*.google.com",
    ]

    protocol {
      port = "443"
      type = "Https"
    }
    protocol {
      port = "80"
      type = "Http"
    }
  }
}

resource "azurerm_firewall_network_rule_collection" "example" {
  name                = "Net-Coll01"
  azure_firewall_name = azurerm_firewall.this.name
  resource_group_name = var.resource_group_name
  priority            = 200
  action              = "Allow"

  rule {
    name = "Allow-DNS"

    source_addresses = [
      "192.168.2.0/24",
    ]

    destination_ports = [
      "53",
    ]

    destination_addresses = [
      "209.244.0.3",
      "209.244.0.4",
    ]

    protocols = [
      "UDP",
    ]
  }
}

resource "azurerm_firewall_nat_rule_collection" "example" {
  name                = "rdp"
  azure_firewall_name = azurerm_firewall.this.name
  resource_group_name = var.resource_group_name
  priority            = 200
  action              = "Dnat"

  rule {
    name = "rdp-nat"

    source_addresses = [
      "*",
    ]

    destination_ports = [
      "3389",
    ]

    destination_addresses = [
      azurerm_public_ip.this.ip_address
    ]

    translated_port = 3389

    translated_address = var.vm1_private_ip

    protocols = [
      "TCP",
      "UDP",
    ]
  }
}

output "firewall_private_ip_address" {
  value = azurerm_firewall.this.ip_configuration[0].private_ip_address
}

output "firewall_public_ip_address" {
  value = azurerm_public_ip.this.ip_address
}