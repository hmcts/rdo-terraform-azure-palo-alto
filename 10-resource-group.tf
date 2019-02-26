resource "azurerm_resource_group" "rg_firewall" {
  name     = "${var.rg_name}"
  location = "${var.rg_location}"
}
