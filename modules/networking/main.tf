data "azurerm_resource_group" "main" {
  name = var.resource_group
}

# Network Security Group
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.cluster_name}-${var.environment}-${var.name_suffix}-${var.target}-nsg"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
}

resource "azurerm_network_security_rule" "ns_rules" {
  count                       = length(var.ns_rules)
  name                        = lookup(var.ns_rules[count.index], "name", "default_rule")
  priority                    = var.ns_rules[count.index]["priority"]
  direction                   = lookup(var.ns_rules[count.index], "direction", "Any")
  access                      = lookup(var.ns_rules[count.index], "access", "Allow")
  protocol                    = lookup(var.ns_rules[count.index], "protocol", "*")
  source_port_range           = lookup(var.ns_rules[count.index], "source_port_range", "*")
  destination_port_range      = lookup(var.ns_rules[count.index], "destination_port_range", "*")
  source_address_prefix       = lookup(var.ns_rules[count.index], "source_address_prefix", "*")
  destination_address_prefix  = lookup(var.ns_rules[count.index], "destination_address_prefix", "*")
  description                 = lookup(var.ns_rules[count.index], "description", "Security rule for ${lookup(var.ns_rules[count.index], "name", "default_rule")}")
  resource_group_name         = data.azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# Load Balancer Configuration
resource "azurerm_public_ip" "public_ip" {
  count               = length(var.public_ips)
  name                = "${var.cluster_name}-${var.environment}-${values(var.public_ips)[count.index].target}-${var.name_suffix}-${values(var.public_ips)[count.index].name}-pip"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  sku                 = var.sku
  allocation_method   = "Static"

  tags = merge(var.default_tags, { "cluster" = "${var.cluster_name}-${var.environment}-${var.name_suffix}" })
}

resource "azurerm_lb" "load_balancer_public" {
  name                = "${var.cluster_name}-${var.environment}-${var.target}-${var.name_suffix}-lb-public"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  sku                 = var.sku

  dynamic "frontend_ip_configuration" {
    iterator = pub
    for_each = azurerm_public_ip.public_ip
    content {
      name                 = "${pub.value.name}-frontend"
      public_ip_address_id = pub.value.id
    }
  }

  tags = merge(var.default_tags, { "cluster" = "${var.cluster_name}-${var.environment}-${var.name_suffix}" })
}

resource "azurerm_lb" "load_balancer_private" {
  name                = "${var.cluster_name}-${var.environment}-${var.target}-${var.name_suffix}-lb-private"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  sku                 = var.sku

  dynamic "frontend_ip_configuration" {
    iterator = priv
    for_each = var.private_ips
    content {
      name                          = "${var.cluster_name}-${var.environment}-${priv.value.target}-${var.name_suffix}-${priv.value.name}-ip-frontend"
      private_ip_address_allocation = priv.value.address_allocation
      private_ip_address            = priv.value.address_allocation == "Static" ? priv.value.ip_address : ""
      subnet_id                     = var.subnet_id
    }
  }

  tags = merge(var.default_tags, { "cluster" = "${var.cluster_name}-${var.environment}-${var.name_suffix}" })
}

resource "azurerm_lb_backend_address_pool" "address_pool_public" {
  name            = "${var.cluster_name}-${var.environment}-${var.target}-${var.name_suffix}-addresspool"
  loadbalancer_id = azurerm_lb.load_balancer_public.id
}

resource "azurerm_lb_backend_address_pool" "address_pool_private" {
  name            = "${var.cluster_name}-${var.environment}-${var.target}-${var.name_suffix}-addresspool"
  loadbalancer_id = azurerm_lb.load_balancer_private.id
}

locals {
  lb_ports_private = [for v in var.lb_ports : v if v.visibility == "private"]
  lb_ports_public  = [for v in var.lb_ports : v if v.visibility == "public"]
}

resource "azurerm_lb_rule" "lb_rule_public" {
  count                          = length(local.lb_ports_public)
  loadbalancer_id                = azurerm_lb.load_balancer_public.id
  name                           = local.lb_ports_public[count.index].name
  protocol                       = local.lb_ports_public[count.index].protocol
  frontend_port                  = local.lb_ports_public[count.index].port
  backend_port                   = local.lb_ports_public[count.index].lb_rule_port_kube_dns
  frontend_ip_configuration_name = "${var.cluster_name}-${var.environment}-${local.lb_ports_public[count.index].target}-${var.name_suffix}-${local.lb_ports_public[count.index].frontend}-pip-frontend"
  enable_floating_ip             = false
  idle_timeout_in_minutes        = 5
  probe_id                       = element(concat(azurerm_lb_probe.lb_probe_public[*].id, [""]), count.index)
  depends_on                     = [azurerm_public_ip.public_ip, azurerm_lb_probe.lb_probe_public]
}

resource "azurerm_lb_rule" "lb_rule_private" {
  count                          = length(local.lb_ports_private)
  loadbalancer_id                = azurerm_lb.load_balancer_private.id
  name                           = local.lb_ports_private[count.index].name
  protocol                       = local.lb_ports_private[count.index].protocol
  frontend_port                  = local.lb_ports_private[count.index].port
  backend_port                   = local.lb_ports_private[count.index].lb_rule_port_kube_dns
  frontend_ip_configuration_name = "${var.cluster_name}-${var.environment}-${local.lb_ports_private[count.index].target}-${var.name_suffix}-${local.lb_ports_private[count.index].frontend}-ip-frontend"
  enable_floating_ip             = false
  idle_timeout_in_minutes        = 5
  probe_id                       = element(concat(azurerm_lb_probe.lb_probe_private[*].id, [""]), count.index)
  depends_on                     = [azurerm_lb_probe.lb_probe_private]
}

resource "azurerm_lb_probe" "lb_probe_public" {
  count               = length(local.lb_ports_public)
  loadbalancer_id     = azurerm_lb.load_balancer_public.id
  name                = local.lb_ports_public[count.index].name
  protocol            = local.lb_ports_public[count.index].health != "" ? "Http" : "Tcp"
  port                = local.lb_ports_public[count.index].lb_rule_port_kube_dns_probe
  interval_in_seconds = var.lb_probe_interval
  number_of_probes    = var.lb_probe_unhealthy_threshold
  request_path        = local.lb_ports_public[count.index].health != "" ? local.lb_ports_public[count.index].health : null
}

resource "azurerm_lb_probe" "lb_probe_private" {
  count               = length(local.lb_ports_private)
  loadbalancer_id     = azurerm_lb.load_balancer_private.id
  name                = local.lb_ports_private[count.index].name
  protocol            = local.lb_ports_private[count.index].health != "" ? "Http" : "Tcp"
  port                = local.lb_ports_private[count.index].lb_rule_port_kube_dns_probe
  interval_in_seconds = var.lb_probe_interval
  number_of_probes    = var.lb_probe_unhealthy_threshold
  request_path        = local.lb_ports_private[count.index].health != "" ? local.lb_ports_private[count.index].health : null
}