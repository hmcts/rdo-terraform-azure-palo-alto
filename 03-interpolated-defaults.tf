locals {
  default_gateway                                   = "${cidrhost(data.azurerm_subnet.subnet.address_prefix,1)}"
  default_gateway_trust                             = "${cidrhost(data.azurerm_subnet.subnet_trust.address_prefix,1)}"
  default_gateway_dmz                               = "${cidrhost(data.azurerm_subnet.subnet_dmz.address_prefix,1)}"
  default_gateway_dmz_trust                         = "${cidrhost(data.azurerm_subnet.subnet_dmz_trust.address_prefix,1)}"
  f5_data_subnet                                    = "${data.azurerm_subnet.subnet_f5_data.address_prefix}"
}

data "azurerm_subnet" "subnet" {
  name                                              = "hub-transit-public"
  virtual_network_name                              = "hmcts-hub-${var.environment}"
  resource_group_name                               = "hmcts-hub-${var.environment}"
  depends_on                                        = ["azurerm_public_ip.palo_mgmt_ip"]
}

data "azurerm_subnet" "subnet_trust" {
  name                                              = "hub-transit-private"
  virtual_network_name                              = "hmcts-hub-${var.environment}"
  resource_group_name                               = "hmcts-hub-${var.environment}"
  depends_on                                        = ["azurerm_public_ip.palo_mgmt_ip"]
}

data "azurerm_subnet" "subnet_dmz" {
  name                                              = "dmz-palo-public"
  virtual_network_name                              = "hmcts-dmz-${var.environment}"
  resource_group_name                               = "hmcts-dmz-${var.environment}"
  depends_on                                        = ["azurerm_public_ip.palo_mgmt_ip"]
}

data "azurerm_subnet" "subnet_dmz_trust" {
  name                                              = "dmz-palo-private"
  virtual_network_name                              = "hmcts-dmz-${var.environment}"
  resource_group_name                               = "hmcts-dmz-${var.environment}"
  depends_on                                        = ["azurerm_public_ip.palo_mgmt_ip"]
}

data "azurerm_subnet" "subnet_f5_data" {
  name                                              = "dmz-loadbalancer"
  virtual_network_name                              = "hmcts-dmz-${var.environment}"
  resource_group_name                               = "hmcts-dmz-${var.environment}"
  depends_on                                        = ["azurerm_public_ip.palo_mgmt_ip"]
}

data "template_file" "inventory" {
    template                                        = "${file("${path.module}/templates/inventory.tpl")}"

    depends_on                                      = [
                                                      "azurerm_virtual_machine.pan_vm"
                                                    ]

    vars = {
        public_ip                                   = "${join("\n", azurerm_public_ip.palo_mgmt_ip.*.ip_address)}"
    }
}