variable "hub_net_address_primary" {
  description = "Network address for the primary hub"
  type        = string
}

variable "bastion_subnet_address_primary" {
  description = "Subnet address for Bastion host in the primary region"
  type        = string
}

variable "enable_primary_vnet_gateway" {
  description = "Flag to enable the Virtual Network Gateway in the primary region"
  type        = bool
}

variable "virtual_network_gateway_subnet_address_primary" {
  description = "Subnet address for the Virtual Network Gateway in the primary region"
  type        = string
}

variable "DNS_server_primary_1" {
  description = "Primary DNS server IP address in the primary region"
  type        = string
}

variable "DNS_server_primary_2" {
  description = "Primary DNS server IP address in the secondary region"
  type        = string
}

variable "vpn_sku_primary" {
  description = "SKU for the VPN Gateway in the primary region"
  type        = string
}

variable "vpn_sku_secondary" {
  description = "SKU for the VPN Gateway in the secondary region"
  type        = string
}

variable "express_route_sku" {
  description = "SKU for the Express Route in the primary region"
  type        = string
}

variable "express_route_sku_secondary" {
  description = "SKU for the Express Route in the Secondary region"
  type        = string
}

variable "enable_primary_afw" {
  description = "Flag to enable Azure Firewall in the primary region"
  type        = bool
}

variable "afw_subnet_address_primary" {
  description = "Subnet address for Azure Firewall in the primary region"
  type        = string
}

variable "afw_sku" {
  description = "SKU for Azure Firewall in the primary region"
  type        = string
}

variable "availibility_zone_1_enabled_primary" {
  description = "Flag to enable availability zone 1 for resources in the primary region"
  type        = bool
}

variable "availibility_zone_2_enabled_primary" {
  description = "Flag to enable availability zone 2 for resources in the primary region"
  type        = bool
}

variable "availibility_zone_3_enabled_primary" {
  description = "Flag to enable availability zone 3 for resources in the primary region"
  type        = bool
}

variable "hub_net_address_secondary" {
  description = "Network address for the secondary hub"
  type        = string
}

variable "DNS_server_secondary_1" {
  description = "Primary DNS server IP address in the secondary region"
  type        = string
}

variable "DNS_server_secondary_2" {
  description = "Secondary DNS server IP address in the secondary region"
  type        = string
}

variable "bastion_subnet_address_secondary" {
  description = "Subnet address for Bastion host in the secondary region"
  type        = string
}

variable "enable_secondary_vnet_gateway" {
  description = "Flag to enable the Virtual Network Gateway in the secondary region"
  type        = bool
}

variable "virtual_network_gateway_subnet_address_secondary" {
  description = "Subnet address for the Virtual Network Gateway in the secondary region"
  type        = string
}

variable "enable_secondary_afw" {
  description = "Flag to enable Azure Firewall in the secondary region"
  type        = bool
}

variable "afw_subnet_address_secondary" {
  description = "Subnet address for Azure Firewall in the secondary region"
  type        = string
}

variable "availibility_zone_1_enabled_secondary" {
  description = "Flag to enable availability zone 1 for resources in the secondary region"
  type        = bool
}

variable "availibility_zone_2_enabled_secondary" {
  description = "Flag to enable availability zone 2 for resources in the secondary region"
  type        = bool
}

variable "availibility_zone_3_enabled_secondary" {
  description = "Flag to enable availability zone 3 for resources in the secondary region"
  type        = bool
}