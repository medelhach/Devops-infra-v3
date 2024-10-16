####
variable "resource_group" {
  type = string
}

variable "lb_type" {
  type    = string
  default = "public"
}

variable "cluster_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "name_suffix" {
  type = string
}

variable "target" {
  type    = string
  default = "workers"
}

variable "sku" {
  type    = string
  default = "Basic"
}

variable "lb_ports" {
  type    = list(map(string))
  default = []
}

variable "public_ips" {
  type    = map(map(string))
  default = {}
}

variable "private_ips" {
  type    = map(map(string))
  default = {}
}

variable "lb_probe_interval" {
  type    = number
  default = 5
}

variable "lb_probe_unhealthy_threshold" {
  type    = number
  default = 2
}

variable "subnet_id" {
  type    = string
  default = ""
}

variable "frontend_private_ip_address_allocation" {
  type    = string
  default = "Dynamic"
}

variable "frontend_private_ip_address" {
  type    = string
  default = ""
}

variable "default_tags" {
  type    = map(string)
  default = {}
}

variable "ns_rules" {
  type = list(map(string))
  default = []
}

##### VMS


variable "location" {
  type    = string
  default = "eastus"
}

variable "vm_admin_username" {
  type    = string
  default = "azureuser"
}

variable "vm_admin_password" {
  type      = string
  sensitive = true
}

variable "vm_size" {
  type    = string
  default = "Standard_D2plds_v5"
}