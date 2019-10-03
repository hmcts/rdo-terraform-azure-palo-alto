resource "azurerm_resource_group" "rg_firewall" {
  name                                              = "${var.rg-name}"
  location                                          = "${var.rg_location}"
}
