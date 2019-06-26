resource "azurerm_availability_set" "availability_set" {
  name                                              = "fw_${var.environment}_avs"
  resource_group_name                               = "${azurerm_resource_group.rg_firewall.name}"
  location                                          = "${azurerm_resource_group.rg_firewall.location}"
  platform_update_domain_count                      = "${var.avail_update_domains}"
  platform_fault_domain_count                       = "${var.avail_fault_domains}"
  managed                                           = "${var.avail_managed}"
}
