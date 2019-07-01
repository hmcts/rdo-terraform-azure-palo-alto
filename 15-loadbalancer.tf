
resource "azurerm_lb" "lb" {
  name                                              = "fw-${var.environment}-palo-lb"
  location                                          = "${azurerm_resource_group.rg_firewall.location}"
  resource_group_name                               = "${azurerm_resource_group.rg_firewall.name}"
  sku                                               = "Standard"
  frontend_ip_configuration {
    name                                            = "frontend"
    subnet_id                                       = "${var.subnet_transit_public_id}"
  }
}

resource "azurerm_lb_backend_address_pool" "lb_backend" {
  name                                              = "fw-${var.environment}-lb-backend"
  resource_group_name                               = "${azurerm_resource_group.rg_firewall.name}"
  loadbalancer_id                                   = "${azurerm_lb.lb.id}"  #"${element(azurerm_lb.lb.*.id, count.index)}"
}

resource "azurerm_lb_probe" "lb_probe" {
  resource_group_name                               = "${azurerm_resource_group.rg_firewall.name}"
  loadbalancer_id                                   = "${azurerm_lb.lb.id}"  #"${element(azurerm_lb.lb.*.id, count.index)}"
  name                                              = "probe-https"
  port                                              = "443"
  protocol                                          = "Tcp"
}

resource "azurerm_lb_rule" "lb_rule" {
  name                                              = "fw-${var.environment}-lbrules"
  resource_group_name                               = "${azurerm_resource_group.rg_firewall.name}"
  loadbalancer_id                                   = "${azurerm_lb.lb.id}"  #"${element(azurerm_lb.lb.*.id, count.index)}"
  frontend_port                                     = "Any" 
  frontend_ip_configuration_name                    = "frontend"
  backend_address_pool_id                           = "${azurerm_lb_backend_address_pool.lb_backend.id}"
  backend_port                                      = "Any"
  protocol                                          = "tcp"
  enable_floating_ip                                = "true"
  probe_id                                          = "${azurerm_lb_probe.lb_probe.id}"
}

resource "azurerm_network_interface_backend_address_pool_association" "lbmap" {
  count                                             = "${var.replicas}"
  network_interface_id                              = "${element(azurerm_network_interface.nic_transit_public.*.id, count.index)}"
  ip_configuration_name                             = "fw-${var.environment}-nic-transit-public-ip-${count.index}"
  backend_address_pool_id                           = "${azurerm_lb_backend_address_pool.lb_backend.id}"
}
