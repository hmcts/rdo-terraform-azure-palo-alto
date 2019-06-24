output "loadbalancer_ip" {
  value                                             = "${azurerm_lb.lb.*.private_ip_address}"
}
