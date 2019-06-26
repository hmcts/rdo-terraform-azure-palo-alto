/*
data "template_file" "inventory" {
    template                                                = "${file("${path.module}/templates/inventory.tpl")}"

    depends_on                                              = [
                                                                "azurerm_virtual_machine.pan_vm"
                                                            ]

    vars = {
        admin_username                                      = "${var.vm_username}"
        admin_password                                      = "${var.vm_password}"
        public_ip                                           = "${join("\n", azurerm_network_interface.nic_mgmt.*.private_ip_address)}"
    }
}

resource "null_resource" "update_inventory" {

    triggers = {
        template                                            = "${data.template_file.inventory.rendered}"
    }

    provisioner "local-exec" {
        command                                             = "echo '${data.template_file.inventory.rendered}' > ${path.module}/ansible/inventory"
    }
}

*/

resource "azurerm_virtual_machine" "ansible-host" {
  name                                                      = "fw-${var.environment}-ansible"
  location                                                  = "${azurerm_resource_group.rg_firewall.location}"
  resource_group_name                                       = "${azurerm_resource_group.rg_firewall.name}"
  network_interface_ids                                     = "${azurerm_network_interface.nic_mgmt.*.id}"
  vm_size                                                   = "Basic_A0"
  delete_os_disk_on_termination                             = true
  
  storage_image_reference {
    publisher                                               = "Canonical"
    offer                                                   = "UbuntuServer"
    sku                                                     = "18.04-LTS"
    version                                                 = "latest"
  }
  
  storage_os_disk {
    name                                                    = "fw-${var.environment}-ansible-os"
    caching                                                 = "ReadWrite"
    create_option                                           = "FromImage"
    managed_disk_type                                       = "Standard_LRS"
  }
  
  os_profile {
    computer_name                                           = "fw-${var.environment}-vm-"
    admin_username                                          = "${var.vm_username}"
    admin_password                                          = "${var.vm_password}"
  }


provisioner "remote-exec" {
    inline                                                  = [
                                                                "mkdir ~/ansible"
                                                            ]
      connection {
    type                                                    = "ssh"
    user                                                    = "${var.vm_username}"
    password                                                = "${var.vm_password}"
    host                                                    = "${azurerm_public_ip.pip-ansible.*.ip_address}"

 }
}

  os_profile_linux_config {
    disable_password_authentication                         = false
  }


}



resource "azurerm_virtual_machine_extension" "ansible_extension" {
  name                                                      = "Ansible-Agent-Install"
  location                                                  = "${azurerm_resource_group.rg_firewall.location}"
  resource_group_name                                       = "${azurerm_resource_group.rg_firewall.name}"
  virtual_machine_name                                      = "${azurerm_virtual_machine.ansible-host.name}"
  publisher                                                 = "Microsoft.Azure.Extensions"
  type                                                      = "CustomScript"
  type_handler_version                                      = "2.0"

  settings                                                  = <<SETTINGS
                                                                {
                                                                    "commandToExecute": "sudo apt-add-repository --yes --update ppa:ansible/ansible",
                                                                    "commandToExecute": "sudo apt-get update && sudo apt install -y software-properties-common ansible libssl-dev libffi-dev python-dev python-pip && sudo pip install pywinrm && sudo pip install azure-keyvault"
                                                                }
                                                            SETTINGS
}



resource "azurerm_network_interface" "ansible_server_nic" {
  name                                                      = "fw-${var.environment}-ansible-nic"
  location                                                  = "${azurerm_resource_group.rg_firewall.location}"
  resource_group_name                                       = "${azurerm_resource_group.rg_firewall.name}"

    ip_configuration {
        name                                                = "fw-${var.environment}-ansible-ip"
        subnet_id                                           = "${var.subnet_management_id}"
        private_ip_address_allocation                       = "dynamic"
        public_ip_address_id                                = "${azurerm_public_ip.pip-ansible.id}"
    }
}

/*

resource "azurerm_public_ip" "pip-ansible" {
  name                                                     = "fw-${var.environment}-ansible-pip"
  location                                                  = "${azurerm_resource_group.rg_firewall.location}"
  resource_group_name                                       = "${azurerm_resource_group.rg_firewall.name}"
  allocation_method                                         = "Static"
 }

resource "null_resource" "ansible-runs" {
    triggers                                                = {
      always_run                                            = "${timestamp()}"
    }

    depends_on                                              = [
                                                                "azurerm_virtual_machine.pan_vm",
                                                                "azurerm_network_interface.ansible_server_nic",
                                                                "azurerm_public_ip.pip-ansible",
                                                                "azurerm_virtual_machine_extension.ansible_extension",
                                                                "azurerm_virtual_machine.ansible-host"
                                                            ]

  provisioner "file" {
    source                                                  = "${path.module}/ansible/"
    destination                                             = "~/ansible/"
  
    connection {
      type                                                  = "ssh"
      user                                                  = "${var.vm_username}"
      password                                              = "${var.vm_password}"
      host                                                  = "${azurerm_public_ip.pip-ansible.*.ip_address}"
    }
  }

  provisioner "remote-exec" {
    inline                                                  = [
                                                                "ansible-playbook -i ~/ansible/inventory ~/ansible/palo.yml"
                                                            ]


    connection {
      type                                                  = "ssh"
      user                                                  = "${var.vm_username}"
      password                                              = "${var.vm_password}"
      host                                                  = "${azurerm_public_ip.pip-ansible.*.ip_address}"
    }
  }
}

*/
