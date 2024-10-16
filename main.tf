module "networking" {
  source        = "./modules/networking"
  resource_group = var.resource_group
  cluster_name   = var.cluster_name
  environment    = var.environment
  name_suffix    = var.name_suffix
  target         = var.target
  sku            = var.sku
  lb_ports       = var.lb_ports
  public_ips     = var.public_ips
  private_ips    = var.private_ips
  lb_probe_interval = var.lb_probe_interval
  lb_probe_unhealthy_threshold = var.lb_probe_unhealthy_threshold
  subnet_id      = var.subnet_id
  frontend_private_ip_address_allocation = var.frontend_private_ip_address_allocation
  frontend_private_ip_address = var.frontend_private_ip_address
  default_tags   = var.default_tags
  ns_rules       = var.ns_rules
}

##### VMS


module "virtual_machines" {
  source              = "./modules/virtual_machines"
  cluster_name        = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group
  subnet_id           = var.subnet_id
  rancher_vm_count    = 2
  workload_vm_count   = 2
  vm_size             = "Standard_D2plds_v5"
  vm_admin_username   = var.vm_admin_username
  vm_admin_password   = var.vm_admin_password
  os_disk_size_gb     = 50
  data_disk_size_gb   = 50
  default_tags        = merge(var.default_tags, {
    environment = var.environment
    project     = "k8s-rancher"
  })
}