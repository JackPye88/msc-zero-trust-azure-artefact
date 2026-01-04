
locals {
  eligible_keyvault_ips = compact(concat(
    [for kv in local.KeyVault : kv.primary_ip if kv.deploy_primary],
    [for kv in local.KeyVault : kv.secondary_ip if kv.deploy_secondary]
  ))

  # Check if any deploy_primary is true
  kv_any_primary_deployed = length([for kv in local.KeyVault : kv if kv.deploy_primary]) > 0
  # Aggregates eligible primary IPs or returns false if none are deployed
  eligible_primary_keyvault_ips = local.kv_any_primary_deployed ? compact(
    concat(
      [for kv in local.KeyVault : kv.primary_ip if kv.deploy_primary],
      var.kv_base_build_custom_primary_ip
  )) : []


  # Check if any deploy_secondary is true
  kv_any_secondary_deployed = length([for kv in local.KeyVault : kv if kv.deploy_secondary]) > 0
  # Aggregates eligible secondary IPs or returns false if none are deployed
  eligible_secondary_keyvault_ips = local.kv_any_secondary_deployed ? compact(
    concat(
      [for kv in local.KeyVault : kv.secondary_ip if kv.deploy_secondary],
      var.kv_base_build_custom_secondary_ip
  )) : []

  adosha_ip = "172.16.5.11"
}



# Create a single Firewall Policy Rule Collection Group for all eligible KeyVaults
resource "azurerm_firewall_policy_rule_collection_group" "keyvault_policy_group" {
  provider           = azurerm.connectivity
  name               = "rcg_${var.environment}_KeyVault-basebuild"
  firewall_policy_id = data.azurerm_firewall_policy.example.id
  priority           = var.kv_rules_priority

  network_rule_collection {
    name     = "rc-${var.environment}_KeyVault-basebuild-net"
    action   = "Allow"
    priority = var.kv_rules_priority

    rule {
      name                  = "BaseBuild_${var.environment}_ADOSHA_to_KeyVault"
      source_addresses      = [local.adosha_ip]
      destination_addresses = local.kv_any_secondary_deployed ? concat(local.eligible_primary_keyvault_ips, local.eligible_secondary_keyvault_ips) : local.eligible_primary_keyvault_ips
      destination_ports     = ["443"]
      protocols             = ["TCP"]
    }
  }
}

# Conditionally create an NSG if any_primary_deployed is true
resource "azurerm_network_security_rule" "keyvault_nsg_primary" {
  count                        = local.kv_any_primary_deployed ? 1 : 0
  name                         = "BaseBuild_${var.environment}_ADOSHA_To_KeyVault"
  priority                     = var.kv_rules_priority + 1
  direction                    = "Inbound"
  access                       = "Allow"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "443"
  source_address_prefixes      = [local.adosha_ip]
  destination_address_prefixes = local.eligible_primary_keyvault_ips
  network_security_group_name  = "nsg-${module.subnet_creation["pe_subnet-primary"].subnet_name}"
  resource_group_name          = azurerm_resource_group.rg-primary["spoke_RG"].name
}

# Conditionally create an NSG if any_secondary_deployed is true
resource "azurerm_network_security_rule" "keyvault_nsg_secondary" {
  count                        = local.kv_any_secondary_deployed ? 1 : 0
  name                         = "BaseBuild_${var.environment}_ADOSHA_To_KeyVault"
  priority                     = var.kv_rules_priority + 2
  direction                    = "Inbound"
  access                       = "Allow"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "443"
  source_address_prefixes      = [local.adosha_ip]
  destination_address_prefixes = local.eligible_secondary_keyvault_ips
  network_security_group_name  = "nsg-${module.subnet_creation["pe_subnet-secondary"].subnet_name}"
  resource_group_name          = azurerm_resource_group.rg-secondary["spoke_RG"].name
}

# Conditionally create an NSG if any_primary_deployed is true
resource "azurerm_network_security_rule" "keyvault_mgmt_nsg_primary" {
  provider                     = azurerm.management
  count                        = local.kv_any_primary_deployed ? 1 : 0
  name                         = "BaseBuild_${var.environment}_ADOSHA_To_KeyVault_primary"
  priority                     = var.kv_rules_priority + 3
  direction                    = "Outbound"
  access                       = "Allow"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "443"
  source_address_prefixes      = [local.adosha_ip]
  destination_address_prefixes = local.eligible_primary_keyvault_ips
  network_security_group_name  = "nsg-snet-mgmt-virtualmachines-${var.primary_short}-001"
  resource_group_name          = "rg-${var.root_id}-mgmt-spoke-${var.primary_short}-001"
}

# Conditionally create an NSG if any_primary_deployed is true
resource "azurerm_network_security_rule" "keyvault_mgmt_nsg_secondary" {
  provider                     = azurerm.management
  count                        = local.kv_any_secondary_deployed ? 1 : 0
  name                         = "BaseBuild_${var.environment}_ADOSHA_To_KeyVault_secondary"
  priority                     = var.kv_rules_priority + 4
  direction                    = "Outbound"
  access                       = "Allow"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "443"
  source_address_prefixes      = [local.adosha_ip]
  destination_address_prefixes = local.eligible_secondary_keyvault_ips
  network_security_group_name  = "nsg-snet-mgmt-virtualmachines-${var.secondary_short}-001"
  resource_group_name          = "rg-${var.root_id}-mgmt-spoke-${var.secondary_short}-001"
}