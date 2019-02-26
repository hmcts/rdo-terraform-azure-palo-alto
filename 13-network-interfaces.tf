resource "azurerm_network_interface" "nic_mgmt" {
  name                = "nic-dmz-firewall-mgmt-${count.index}"
  location            = "${azurerm_resource_group.rg_firewall.location}"
  resource_group_name = "${azurerm_resource_group.rg_firewall.name}"
  count               = "${var.replicas}"

  ip_configuration {
    name                          = "ip-dmz-firewall-mgmt-${count.index}"
    subnet_id                     = "${var.subnet_management_id}"
    private_ip_address_allocation = "dynamic"
  }
}

resource "azurerm_network_interface" "nic_transit" {
  count               = "${var.replicas}"
  name                = "nic-dmz-firewall-transit-${count.index}"
  location            = "${azurerm_resource_group.rg_firewall.location}"
  resource_group_name = "${azurerm_resource_group.rg_firewall.name}"
  enable_ip_forwarding          = "true"

  ip_configuration {
    name                          = "ip-dmz-firewall-transit-${count.index}"
    subnet_id                     = "${var.subnet_transit_id}"
    private_ip_address_allocation = "dynamic"
  }
}
