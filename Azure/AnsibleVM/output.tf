output "virtual_network_id" {
  value = module.virtual_network.virtual_network_id
}

output "pip_0" {
  value = "ssh azureuser@${module.linux_virtual_machine.pip_0}"
}

output "pip_1" {
  value = module.linux_virtual_machine.pip_1
}

output "name" {
  value = module.linux_virtual_machine.private_ip
}