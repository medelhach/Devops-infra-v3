/* resource "azurerm_availability_set" "vm_avset" {
  name                         = "${var.cluster_name}-avset"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 5
  managed                      = true
}
*/


resource "azurerm_network_interface" "vm_nic" {
  count               = var.rancher_vm_count + var.workload_vm_count
  name                = "${var.cluster_name}-${count.index < var.rancher_vm_count ? "rancher" : "worker"}-nic-${count.index + 1}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  count                 = var.rancher_vm_count + var.workload_vm_count
  name                  = "${var.cluster_name}-${count.index < var.rancher_vm_count ? "rancher" : "worker"}-${count.index + 1}"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.vm_nic[count.index].id]
  size                  = var.vm_size
  admin_username        = var.vm_admin_username
  zone                  = "1"

  admin_password                  = var.vm_admin_password
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-arm64"
    version   = "latest"
  }

  tags = merge(var.default_tags, {
    "vm-type" = count.index < var.rancher_vm_count ? "rancher" : "worker"
  })
}

resource "azurerm_managed_disk" "data_disk" {
  count                = var.workload_vm_count
  name                 = "${var.cluster_name}-worker-data-disk-${count.index + 1}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.data_disk_size_gb
  zone                 = "1"
}

resource "azurerm_virtual_machine_data_disk_attachment" "data_disk_attachment" {
  count              = var.workload_vm_count
  managed_disk_id    = azurerm_managed_disk.data_disk[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.vm[var.rancher_vm_count + count.index].id
  lun                = "10"
  caching            = "ReadWrite"
}