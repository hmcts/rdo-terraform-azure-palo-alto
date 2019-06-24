resource "azurerm_lb" "lb" {
  name                                              = "lb-dmz-firewall-${count.index}"
  location                                          = "${azurerm_resource_group.rg_firewall.location}"
  resource_group_name                               = "${azurerm_resource_group.rg_firewall.name}"
  sku                                               = "Standard"
  count                                             = "${var.replicas}"
  frontend_ip_configuration {
    name                                            = "frontend"
    subnet_id                                       = "${var.subnet_transit_public_id}"
  }
}

resource "azurerm_lb_backend_address_pool" "lb_backend" {
  name                                              = "lbb-dmz-firewall"
  resource_group_name                               = "${azurerm_resource_group.rg_firewall.name}"
  loadbalancer_id                                   = "${element(azurerm_lb.lb.*.id, count.index)}"
}

resource "azurerm_network_interface_backend_address_pool_association" "lbmap" {
  count                                             = "${var.replicas}"
  network_interface_id                              = "${element(azurerm_network_interface.nic_transit.*.id, count.index)}"
  ip_configuration_name                             = "ip-dmz-firewall-transit-${count.index}"
  backend_address_pool_id                           = "${element(azurerm_lb_backend_address_pool.lb_backend.*.id, count.index)}"
}

resource "azurerm_lb_probe" "lb_probe" {
  resource_group_name                               = "${azurerm_resource_group.rg_firewall.name}"
  loadbalancer_id                                   = "${element(azurerm_lb.lb.*.id, count.index)}"
  name                                              = "probe-https"
  port                                              = "443"
  protocol                                          = "Tcp"
}

resource "azurerm_lb_rule" "lb_rule" {
  resource_group_name                               = "${azurerm_resource_group.rg_firewall.name}"
  loadbalancer_id                                   = "${element(azurerm_lb.lb.*.id, count.index)}"
  name                                              = "lbrule-firewalls"
  frontend_port                                     = "0"
  frontend_ip_configuration_name                    = "frontend"
  backend_address_pool_id                           = "${azurerm_lb_backend_address_pool.lb_backend.id}"
  backend_port                                      = "0"
  protocol                                          = "All"
  enable_floating_ip                                = "true"
  probe_id                                          = "${azurerm_lb_probe.lb_probe.id}"
}
