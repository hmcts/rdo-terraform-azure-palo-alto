resource "azurerm_virtual_machine" "pan_vm" {
  name                                              = "fw_${var.environment}_vm_${count.index}"
  location                                          = "${azurerm_resource_group.rg_firewall.location}"
  resource_group_name                               = "${azurerm_resource_group.rg_firewall.name}"
  availability_set_id                               = "${azurerm_availability_set.availability_set.id}"
  vm_size                                           = "${var.vm_size}"
  delete_os_disk_on_termination                     = true
  count                                             = "${var.replicas}"

  plan {
    name                                            = "${var.marketplace_sku}"
    publisher                                       = "${var.marketplace_publisher}"
    product                                         = "${var.marketplace_offer}"
  }

  storage_image_reference {
    publisher                                       = "${var.marketplace_publisher}"
    offer                                           = "${var.marketplace_offer}"
    sku                                             = "${var.marketplace_sku}"
    version                                         = "latest"
  }

  storage_os_disk {
    name                                            = "fw_${var.environment}_os_${count.index}"
    managed_disk_type                               = "Standard_LRS"
    caching                                         = "ReadWrite"
    create_option                                   = "FromImage"
  }

  os_profile {
    computer_name                                   = "fw_${var.environment}_vm_${count.index}"
    admin_username                                  = "${var.vm_username}"
    admin_password                                  = "${var.vm_password}"
  }

  primary_network_interface_id                      = "${element(azurerm_network_interface.nic_mgmt.*.id, count.index)}"
  network_interface_ids                             = [
                                                        "${element(azurerm_network_interface.nic_mgmt.*.id, count.index)}",
                                                        "${element(azurerm_network_interface.nic_transit_public.*.id, count.index)}",
                                                        "${element(azurerm_network_interface.nic_transit_private.*.id, count.index)}"
                                                      ]

  os_profile_linux_config {
    disable_password_authentication                 = false
  }
}


data "template_file" "inventory" {
    template                                        = "${file("${path.module}/templates/inventory.tpl")}"

    depends_on                                      = [
                                                        "azurerm_virtual_machine.pan_vm"
                                                      ]

    vars = {
        admin_username                              = "${var.vm_username}"
        admin_password                              = "${var.vm_password}"
        public_ip                                   = "${azurerm_public_ip.pip_mgmt.ip_address}"
    }
}

resource "null_resource" "update_inventory" {

    triggers = {
        template                                     = "${data.template_file.inventory.rendered}"
    }

    provisioner "local-exec" {
        command                                      = "echo '${data.template_file.inventory.rendered}' > ${path.module}/ansible/inventory"
    }
}

resource "null_resource" "ansible-runs" {
    triggers = {
      always_run                                      = "${timestamp()}"
    }

    depends_on                                        = [
                                                          "azurerm_virtual_machine.pan_vm",
                                                          "azurerm_network_interface.nic_mgmt",
                                                          "azurerm_public_ip.pip_mgmt"
                                                      ]

  provisioner "local-exec" {
    command = <<EOF
      echo "hello world"
    EOF
  }
}