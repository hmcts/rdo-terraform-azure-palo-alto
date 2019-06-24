resource "azurerm_network_interface" "nic_mgmt" {
  name                                              = "firewall-${var.environment}-nic-mgmt"
  location                                          = "${azurerm_resource_group.rg_firewall.location}"
  resource_group_name                               = "${azurerm_resource_group.rg_firewall.name}"

  ip_configuration {
    name                                            = "firewall-${var.environment}-nic-mgmt-ip"
    subnet_id                                       = "${var.subnet_management_id}"
    private_ip_address_allocation                   = "dynamic"
  }
}

resource "azurerm_network_interface" "nic_transit_public" {
  name                                              = "firewall-${var.environment}-nic-transit-public"
  location                                          = "${azurerm_resource_group.rg_firewall.location}"
  resource_group_name                               = "${azurerm_resource_group.rg_firewall.name}"
  enable_ip_forwarding                              = "true"

  ip_configuration {
    name                                            = "${azurerm_network_interface.nic_transit_public.name}"
    subnet_id                                       = "${var.subnet_transit_id}"
    private_ip_address_allocation                   = "dynamic"
  }
}


resource "azurerm_network_interface" "nic_transit_private" {
  name                                              = "firewall-${var.environment}-nic-transit-private"
  location                                          = "${azurerm_resource_group.rg_firewall.location}"
  resource_group_name                               = "${azurerm_resource_group.rg_firewall.name}"
  enable_ip_forwarding                              = "true"

  ip_configuration {
    name                                            = "${azurerm_network_interface.nic_transit_private.name}"
    subnet_id                                       = "${var.subnet_transit_id}"
    private_ip_address_allocation                   = "dynamic"
  }
}