variable "name" {
  type    = string
  default = "VNet1"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "address_space" {
  type        = list(string)
  description = "The name of the resource group in which to create the virtual network."
  default     = ["10.1.0.0/16"]
}

variable "subnets_name" {
  type        = list(string)
  description = "The name of the subnet"
  default     = ["GatewaySubnet", "FrontEnd"]
}

variable "subnets_prefixes" {
  type        = list(string)
  description = "The address prefixes for the subnet"
  default     = ["10.1.255.0/27", "10.1.0.0/24"]
}