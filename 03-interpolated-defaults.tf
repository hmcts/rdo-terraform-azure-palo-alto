locals {
  default_gateway                                   = "${cidrhost(data.azurerm_subnet.subnet.address_prefix,0)}"
}

data "azurerm_subnet" "subnet" {
  name                                              = "sub-hub-mgmt"
  virtual_network_name                              = "hub"
  resource_group_name                               = "hub"
}


data "template_file" "inventory" {
    template                                                = "${file("${path.module}/templates/inventory.tpl")}"

    depends_on                                              = [
                                                                "azurerm_virtual_machine.pan_vm"
                                                            ]

    vars = {
        public_ip                                           = "${join("\n", azurerm_public_ip.palo_public_ip.*.ip_address)}"
    }
}