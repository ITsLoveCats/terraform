variable "location" {
  type    = string
  default = "eastus"

}

variable "vngw_pip" {
  type    = string
  default = "vngwpip"
}

variable "vngw_name" {
  type        = string
  description = "value"
  default     = "VNet1GW"

}

variable "vpn_client_address_space" {
  default = ["172.16.0.0/24"]
}