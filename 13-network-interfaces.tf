resource "azurerm_public_ip" "pip_mgmt" {
  name                                              = "fw-${var.environment}-pip"
  location                                          = "${azurerm_resource_group.rg_firewall.location}"
  resource_group_name                               = "${azurerm_resource_group.rg_firewall.name}"
  allocation_method                                 = "Static"
}


resource "azurerm_network_interface" "nic_mgmt" {
  name                                              = "fw-${var.environment}-nic-mgmt-${count.index}"
  location                                          = "${azurerm_resource_group.rg_firewall.location}"
  resource_group_name                               = "${azurerm_resource_group.rg_firewall.name}"
  count                                             = "${var.replicas}"

  ip_configuration {
    name                                            = "fw-${var.environment}-nic-mgmt-ip-${count.index}"
    subnet_id                                       = "${var.subnet_management_id}"
    private_ip_address_allocation                   = "dynamic"
    #public_ip_address_id                            = "${azurerm_public_ip.pip_mgmt.id}"
  }
}

resource "azurerm_network_interface" "nic_transit_public" {
  name                                              = "fw-${var.environment}-nic-transit-public-${count.index}"
  location                                          = "${azurerm_resource_group.rg_firewall.location}"
  resource_group_name                               = "${azurerm_resource_group.rg_firewall.name}"
  count                                             = "${var.replicas}"
  enable_ip_forwarding                              = "true"

  ip_configuration {
    name                                            = "fw-${var.environment}-nic-transit-public-ip-${count.index}"
    subnet_id                                       = "${var.subnet_transit_public_id}"
    private_ip_address_allocation                   = "dynamic"
  }
}


resource "azurerm_network_interface" "nic_transit_private" {
  name                                              = "fw-${var.environment}-nic-transit-private-${count.index}"
  location                                          = "${azurerm_resource_group.rg_firewall.location}"
  resource_group_name                               = "${azurerm_resource_group.rg_firewall.name}"
  count                                             = "${var.replicas}"
  enable_ip_forwarding                              = "true"

  ip_configuration {
    name                                            = "fw-${var.environment}-nic-transit-private-ip-${count.index}"
    subnet_id                                       = "${var.subnet_transit_private_id}"
    private_ip_address_allocation                   = "dynamic"
  }
}