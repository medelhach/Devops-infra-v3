variable "cluster_name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "rancher_vm_count" {
  type    = number
  default = 2
}

variable "workload_vm_count" {
  type    = number
  default = 2
}


variable "vm_admin_username" {
  type = string
}

variable "vm_admin_password" {
  type = string
}

variable "os_disk_size_gb" {
  type    = number
  default = 50
}

variable "data_disk_size_gb" {
  type    = number
  default = 50
}

variable "default_tags" {
  type = map(string)
}


variable "vm_size" {
  type    = string
  default = "Standard_D2plds_v5"
}
