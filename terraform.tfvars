resource_group = "devops-RG-v2"
cluster_name   = "my-cluster-name"
environment    = "staging"
name_suffix    = "abc123"


#### VMS

location          = "eastus"
vm_admin_username = "azureuser"
vm_admin_password = "Azerty@123456"
###3

# Optional variables with example values
lb_type = "public"  # Can be either "public" or "private"

sku = "Standard"  # Can be "Basic" or "Standard"

public_ips = {
  cockroach = {
    name   = "cockroach"
    target = "workers"
  }
}

private_ips = {
  dns = {
    name                = "dns"
    target              = "workers"
    address_allocation  = "Static"
    ip_address          = "10.0.0.10"
  }
}

lb_ports = [
  {
    name                    = "dns"
    port                    = "53"
    protocol                = "Udp"
    lb_rule_port_kube_dns   = "53"
    lb_rule_port_kube_dns_probe = "53"
    health                  = ""
    target                  = "workers"
    frontend                = "dns"
    visibility              = "private"
  },
  {
    name                    = "grpc"
    port                    = "26257"
    protocol                = "Tcp"
    lb_rule_port_kube_dns   = "26257"
    lb_rule_port_kube_dns_probe = "26257"
    health                  = ""
    target                  = "workers"
    frontend                = "cockroach"
    visibility              = "public"
  }
]

lb_probe_interval = 5
lb_probe_unhealthy_threshold = 2

vm_size = "Standard_D2plds_v5"


subnet_id = "/subscriptions/a60a21a6-e1d6-4313-b82a-8121eae81ea7/resourceGroups/devops-RG-v2/providers/Microsoft.Network/virtualNetworks/Devops-infra-vnet01/subnets/default"

frontend_private_ip_address_allocation = "Dynamic"  # Or "Static"
frontend_private_ip_address = ""  # Only required if allocation is Static

default_tags = {
  environment = "staging"
  project     = "k8s-load-balancer"
}

ns_rules = [
  {
    name                       = "k8s-services"
    priority                   = "150"
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    destination_port_range     = "30000-32767"
    source_address_prefix      = "Internet"
    destination_address_prefix = "VirtualNetwork"
    description                = "Port range for Kubernetes services"
  }
]

