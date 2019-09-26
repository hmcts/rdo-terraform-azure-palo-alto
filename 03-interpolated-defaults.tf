locals {
  default_gateway                                   = "${cidrhost(data.azurerm_subnet.subnet.address_prefix,1)}"
  default_gateway_trust                             = "${cidrhost(data.azurerm_subnet.subnet_trust.address_prefix,1)}"
}

data "azurerm_subnet" "subnet" {
  name                                              = "sub-hub-transit-public"
  virtual_network_name                              = "hub"
  resource_group_name                               = "hub"
  depends_on                                        = ["azurerm_public_ip.palo_mgmt_ip"]
}

data "azurerm_subnet" "subnet_trust" {
  name                                              = "sub-hub-transit-private"
  virtual_network_name                              = "hub"
  resource_group_name                               = "hub"
  depends_on                                        = ["azurerm_public_ip.palo_mgmt_ip"]
}

data "template_file" "inventory" {
    template                                                = "${file("${path.module}/templates/inventory.tpl")}"

    depends_on                                              = [
                                                                "azurerm_virtual_machine.pan_vm"
                                                            ]

    vars = {
        public_ip                                           = "${join("\n", azurerm_public_ip.palo_mgmt_ip.*.ip_address)}"
    }
}