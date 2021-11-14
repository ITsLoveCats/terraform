provider "azurerm" {
  skip_provider_registration = "true"
  features {}
}

variable "resource_group_name" {}
variable "firewall_private_ip_address" {}

resource "azurerm_route_table" "this" {
  name                          = "Firewall-route"
  location                      = "eastus"
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = false

  route {
    name                   = "fw-dg"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.firewall_private_ip_address
  }

  tags = {
    ManagedBy = "terraform"
  }
}

output "route_table_id" {
  value = azurerm_route_table.this.id
}
