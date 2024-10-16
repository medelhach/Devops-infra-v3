output "public_lb_id" {
  value = azurerm_lb.load_balancer_public.id
}

output "private_lb_id" {
  value = azurerm_lb.load_balancer_private.id
}

output "public_ip_addresses" {
  value = { for pip in azurerm_public_ip.public_ip : pip.name => pip.ip_address }
}

output "public_backend_address_pool_id" {
  value = azurerm_lb_backend_address_pool.address_pool_public.id
}

output "private_backend_address_pool_id" {
  value = azurerm_lb_backend_address_pool.address_pool_private.id
}

output "network_security_group_id" {
  value = azurerm_network_security_group.nsg.id
}

output "network_security_group_name" {
  value = azurerm_network_security_group.nsg.name
}
