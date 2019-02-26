variable "rg_location" {
  description = "Location to build all the resources in"
  default     = "UK South"
}

variable "replicas" {
  description = "How many palo alto firewalls to deploy"
  default     = 1
}

variable "marketplace_sku" {
  description = "SKU of the firewall from the marketplace"
  default     = "bundle2"
}

variable "marketplace_publisher" {
  description = "Publisher in the marketplace for the firewall"
  default     = "paloaltonetworks"
}

variable "marketplace_offer" {
  description = "Offer in the marketplace for the firewall"
  default     = "vmseries1"
}

variable "vm_size" {
  description = "Virtual machine size to use for the firewall"
  default     = "Standard_D3_v2"
}

variable "avail_update_domains" {
  description = "Specifies the number of update domains that are used"
  default     = 2
}

variable "avail_fault_domains" {
  description = "Specifies the number of fault domains that are used"
  default     = 2
}

variable "avail_managed" {
  description = "Specifies whether the availability set is managed or not"
  default     = true
}
