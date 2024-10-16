output "rancher_vm_ids" {
  value = slice(azurerm_linux_virtual_machine.vm[*].id, 0, var.rancher_vm_count)
}

output "workload_vm_ids" {
  value = slice(azurerm_linux_virtual_machine.vm[*].id, var.rancher_vm_count, var.rancher_vm_count + var.workload_vm_count)
}

output "rancher_private_ips" {
  value = slice(azurerm_network_interface.vm_nic[*].private_ip_address, 0, var.rancher_vm_count)
}

output "workload_private_ips" {
  value = slice(azurerm_network_interface.vm_nic[*].private_ip_address, var.rancher_vm_count, var.rancher_vm_count + var.workload_vm_count)
}
