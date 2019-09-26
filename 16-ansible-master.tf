resource "null_resource" "update_inventory" {

    triggers = {
        template                                            = "${data.template_file.inventory.rendered}"
    }

    provisioner "local-exec" {
        command                                             = "echo '${data.template_file.inventory.rendered}' > ${path.module}/ansible/inventory"
    }
}

resource "azurerm_virtual_machine" "ansible-host" {
  name                                                      = "${var.vnet_name}-${var.environment}-palo-ansible"
  location                                                  = "${azurerm_resource_group.rg_firewall.location}"
  resource_group_name                                       = "${azurerm_resource_group.rg_firewall.name}"
  network_interface_ids                                     = ["${var.ansible-nic}"]
  vm_size                                                   = "Basic_A0"
  delete_os_disk_on_termination                             = true
  
  storage_image_reference {
    publisher                                               = "Canonical"
    offer                                                   = "UbuntuServer"
    sku                                                     = "18.04-LTS"
    version                                                 = "latest"
  }
  
  storage_os_disk {
    name                                                    = "${var.vnet_name}-${var.environment}-palo-ansible-os"
    caching                                                 = "ReadWrite"
    create_option                                           = "FromImage"
    managed_disk_type                                       = "Standard_LRS"
  }
  
  os_profile {
    computer_name                                           = "${var.vnet_name}-${var.environment}-palo-ans-os"
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
    host                                                    = "${var.pip-ansible}"

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
                                                                    "commandToExecute": "sudo apt-get update && sudo apt install -y software-properties-common ansible libssl-dev libffi-dev python-dev python-pip && sudo pip install pywinrm && sudo pip install azure-keyvault && sudo pip install requests && sudo pip install requests-toolbelt"
                                                                }
                                                            SETTINGS
}


resource "null_resource" "ansible-runs" {
    triggers                                                = {
      always_run                                            = "${timestamp()}"
    }

    depends_on                                              = [
                                                                "azurerm_virtual_machine.pan_vm",
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
      host                                                  = "${var.pip-ansible}"
    }
  }

  provisioner "remote-exec" {
    inline                                                  = [
                                                                "sudo apt-get install sshpass",
                                                                "ansible-galaxy install -f PaloAltoNetworks.paloaltonetworks",
                                                                "ansible-playbook -i /home/localadmin/ansible/inventory -vvvvvvv /home/localadmin/ansible/palo.yml -e mgmt_ip=${azurerm_public_ip.palo_mgmt_ip.ip_address} -e admin_username=${var.vm_username} -e admin_password=${var.vm_password} -e paloname=${azurerm_virtual_machine.pan_vm.0.name} -e gateway=${local.default_gateway} -e gateway_trust=${local.default_gateway_trust} -e gateway_dmz=${local.default_gateway_dmz} -e gateway_dmz_trust=${local.default_gateway_dmz_trust}",
                                                            ]
                                                         
    connection {
      type                                                  = "ssh"
      user                                                  = "${var.vm_username}"
      password                                              = "${var.vm_password}"
      host                                                  = "${var.pip-ansible}"
    }
  }
}


