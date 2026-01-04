
resource "azurerm_network_security_rule" "ICMP_Out" {
  provider = azurerm.main

  name                        = "BaseBuild-${var.rule_descriptor}-ICMP_Out"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Icmp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefixes     = [var.primary_region_address]
  destination_address_prefix  = "0.0.0.0/0"
  resource_group_name         = var.primary_nsg_resource_group_name
  network_security_group_name = var.primary_nsg_name
}

resource "azurerm_network_security_rule" "secondary_ICMP_Out" {
  provider                    = azurerm.main
  count                       = var.deploy_secondary ? 1 : 0
  name                        = "BaseBuild-${var.rule_descriptor}-ICMP_Out"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Icmp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefixes     = [var.secondary_region_address]
  destination_address_prefix  = "0.0.0.0/0"
  resource_group_name         = var.secondary_nsg_resource_group_name
  network_security_group_name = var.secondary_nsg_name
}

resource "azurerm_network_security_rule" "ICMP_In" {
  provider = azurerm.main

  name                         = "BaseBuild-${var.rule_descriptor}-ICMP_Inbound"
  priority                     = 101
  direction                    = "Inbound"
  access                       = "Allow"
  protocol                     = "Icmp"
  source_port_range            = "*"
  destination_port_range       = "*"
  source_address_prefixes      = var.on_prem_networks
  destination_address_prefixes = [var.primary_region_address]
  resource_group_name          = var.primary_nsg_resource_group_name
  network_security_group_name  = var.primary_nsg_name
}
resource "azurerm_network_security_rule" "secondary_ICMP_In" {
  provider                     = azurerm.main
  count                        = var.deploy_secondary ? 1 : 0
  name                         = "BaseBuild-${var.rule_descriptor}-ICMP_Inbound"
  priority                     = 101
  direction                    = "Inbound"
  access                       = "Allow"
  protocol                     = "Icmp"
  source_port_range            = "*"
  destination_port_range       = "*"
  source_address_prefixes      = var.on_prem_networks
  destination_address_prefixes = [var.secondary_region_address]
  resource_group_name          = var.secondary_nsg_resource_group_name
  network_security_group_name  = var.secondary_nsg_name
}

resource "azurerm_network_security_rule" "ICMP_Inaz" {
  provider = azurerm.main

  name                         = "BaseBuild-${var.rule_descriptor}-ICMP_AZ_Inbound"
  priority                     = 103
  direction                    = "Inbound"
  access                       = "Allow"
  protocol                     = "Icmp"
  source_port_range            = "*"
  destination_port_range       = "*"
  source_address_prefix        = var.azure_all_networks
  destination_address_prefixes = [var.primary_region_address]
  resource_group_name          = var.primary_nsg_resource_group_name
  network_security_group_name  = var.primary_nsg_name
}
resource "azurerm_network_security_rule" "secondary_ICMP_In_AZ" {
  provider                     = azurerm.main
  count                        = var.deploy_secondary ? 1 : 0
  name                         = "BaseBuild-${var.rule_descriptor}-ICMP_AZ_Inbound"
  priority                     = 103
  direction                    = "Inbound"
  access                       = "Allow"
  protocol                     = "Icmp"
  source_port_range            = "*"
  destination_port_range       = "*"
  source_address_prefix        = var.azure_all_networks
  destination_address_prefixes = [var.secondary_region_address]
  resource_group_name          = var.secondary_nsg_resource_group_name
  network_security_group_name  = var.secondary_nsg_name
}
