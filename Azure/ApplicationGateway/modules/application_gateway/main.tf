provider "azurerm" {
  skip_provider_registration = "true"
  features {}
}

# variable pass from main.tf of different modules
variable "resource_group_name" {}
variable "virtual_network_name" {}
variable "subnet_fe_id" {}
variable "virtual_machine_ip_1" {}
variable "virtual_machine_ip_2" {}
variable "virtual_machine_ip_3" {}

# local variable
variable "location" {
  description = "Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
  default     = "eastus"
}

variable "pip_name" {
  description = "Specifies the name of the Public IP resource . Changing this forces a new resource to be created"
  default     = "agpip"
}

# Resource Public IP for Application Gateway
resource "azurerm_public_ip" "ag_pip" {
  location            = var.location
  resource_group_name = var.resource_group_name

  name              = var.pip_name
  allocation_method = "Static"
  sku               = "Standard"

  tags = {
    environment = "Production"
  }
}

# Resource for Application Gateway
#&nbsp;since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_address_pool_name          = "${var.virtual_network_name}-beap"
  backend_address_pool_name_AzureVM1 = "AzureVM1-beap"
  backend_address_pool_name_AzureVM2 = "AzureVM2-beap"
  backend_address_pool_name_AzureVM3 = "AzureVM3-beap"
  listener_name_AzureVM1             = "AzureVM1-httplstn"
  listener_name_AzureVM2             = "AzureVM2-httplstn"
  listener_name_AzureVM3             = "AzureVM3-httplstn"
  request_routing_rule_name          = "${var.virtual_network_name}-rqrt"
  redirect_configuration_name        = "${var.virtual_network_name}-rdrcfg"

  #common
  listener_name                  = "${var.virtual_network_name}-httplstn"
  frontend_port_name             = "${var.virtual_network_name}-feport"
  frontend_ip_configuration_name = "${var.virtual_network_name}-feip"
  http_setting_name              = "${var.virtual_network_name}-be-htst"
}

resource "azurerm_application_gateway" "network" {
  name                = "appgateway"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = var.subnet_fe_id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.ag_pip.id
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  backend_address_pool {
    name         = local.backend_address_pool_name_AzureVM1
    ip_addresses = ["${var.virtual_machine_ip_1}"]
  }
  backend_address_pool {
    name         = local.backend_address_pool_name_AzureVM2
    ip_addresses = ["${var.virtual_machine_ip_2}"]
  }
  backend_address_pool {
    name         = local.backend_address_pool_name_AzureVM3
    ip_addresses = ["${var.virtual_machine_ip_3}"]
  }

  http_listener {
    name                           = local.listener_name_AzureVM1
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
    host_name                      = "contoso.com"
  }

  http_listener {
    name                           = local.listener_name_AzureVM2
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
    host_name                      = "fabrikam.com"
  }

  http_listener {
    name                           = local.listener_name_AzureVM3
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
    host_name                      = "adatum.com"
  }

  # request_routing_rule {
  #   name                       = local.request_routing_rule_name
  #   rule_type                  = "Basic"
  #   http_listener_name         = local.listener_name
  #   backend_address_pool_name  = local.backend_address_pool_name
  #   backend_http_settings_name = local.http_setting_name
  # }

  request_routing_rule {
    name                       = "AzureVM1-rqrt"
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name_AzureVM1
    backend_address_pool_name  = local.backend_address_pool_name_AzureVM1
    backend_http_settings_name = local.http_setting_name
  }

  request_routing_rule {
    name                       = "AzureVM2-rqrt"
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name_AzureVM2
    backend_address_pool_name  = local.backend_address_pool_name_AzureVM2
    backend_http_settings_name = local.http_setting_name
  }

  request_routing_rule {
    name                       = "AzureVM3-rqrt"
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name_AzureVM3
    backend_address_pool_name  = local.backend_address_pool_name_AzureVM3
    backend_http_settings_name = local.http_setting_name
  }
}

