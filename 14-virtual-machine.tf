resource "azurerm_virtual_machine" "pan_vm" {
  name                = "vm-${var.vm_name_prefix}-${count.index}"
  location            = "${azurerm_resource_group.rg_firewall.location}"
  resource_group_name = "${azurerm_resource_group.rg_firewall.name}"
  availability_set_id = "${azurerm_availability_set.availability_set.id}"
  vm_size             = "${var.vm_size}"
  count               = "${var.replicas}"

  plan {
    name      = "${var.marketplace_sku}"
    publisher = "${var.marketplace_publisher}"
    product   = "${var.marketplace_offer}"
  }

  storage_image_reference {
    publisher = "${var.marketplace_publisher}"
    offer     = "${var.marketplace_offer}"
    sku       = "${var.marketplace_sku}"
    version   = "latest"
  }

  storage_os_disk {
    name              = "hdd-${var.vm_name_prefix}-${count.index}"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  os_profile {
    computer_name  = "vm-${var.vm_name_prefix}-${count.index}"
    admin_username = "${var.vm_username}"
    admin_password = "${var.vm_password}"
  }

  primary_network_interface_id = "${element(azurerm_network_interface.nic_mgmt.*.id, count.index)}"
  network_interface_ids        = [
                                   "${element(azurerm_network_interface.nic_mgmt.*.id, count.index)}",
                                   "${element(azurerm_network_interface.nic_transit.*.id, count.index)}"
                                 ]

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
