variable "location" {
  type        = string
  description = "The Azure location where the Windows Virtual Machine should exist. Changing this forces a new resource to be created."
  default     = "eastus"
}

variable "vm_name" {
  type        = list(string)
  description = "The name of the Windows Virtual Machine. Changing this forces a new resource to be created."
  default     = ["ELK", "LinuxVM2"]
}