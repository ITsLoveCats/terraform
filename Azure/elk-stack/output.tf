output "virtual_network_id" {
  value = module.virtual_network.virtual_network_id
}

output "name" {
  value = module.linux_virtual_machine.private_ip
}

output "pip" {
  value = module.linux_virtual_machine.public_ip
}