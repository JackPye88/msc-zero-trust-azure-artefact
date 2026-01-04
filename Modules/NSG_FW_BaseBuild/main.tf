resource "azurerm_firewall_policy_rule_collection_group" "this" {
  provider = azurerm.connectivity

  #for_each = { for idx, nrc in var.network_rule_collections : idx => nrc if length([for rule in nrc.rules : rule if rule.fw_deploy]) > 0 }

  name               = var.name
  firewall_policy_id = var.firewall_policy_id
  priority           = var.priority

  dynamic "network_rule_collection" {
    for_each = { for idx, nrc in var.network_rule_collections : idx => nrc if length([for rule in nrc.rules : rule if rule.fw_deploy]) > 0 }
    content {
      name     = network_rule_collection.value.name
      priority = network_rule_collection.value.priority
      action   = network_rule_collection.value.action

      dynamic "rule" {
        for_each = [for rule in network_rule_collection.value.rules : rule if rule.fw_deploy]
        content {
          name                  = rule.value.name
          protocols             = rule.value.protocols
          source_addresses      = rule.value.source_addresses
          destination_ports     = rule.value.destination_ports
          destination_addresses = rule.value.destination_addresses
        }
      }
      rule {
        name                  = "BaseBuild-${var.rule_descriptor}-ICMP_In"
        protocols             = ["ICMP"]
        source_addresses      = concat([var.azure_all_networks], var.on_prem_networks)
        destination_ports     = ["*"]
        destination_addresses = concat([var.primary_region_address], [var.secondary_region_address])
      }
    }
  }

  dynamic "application_rule_collection" {
    for_each = var.application_rule_collections
    content {
      name     = application_rule_collection.value.name
      priority = application_rule_collection.value.priority
      action   = application_rule_collection.value.action

      dynamic "rule" {
        for_each = application_rule_collection.value.rules
        content {
          name              = rule.value.name
          source_addresses  = rule.value.source_addresses
          destination_fqdns = rule.value.destination_fqdns

          dynamic "protocols" {
            for_each = rule.value.protocols
            content {
              type = protocols.value.type
              port = protocols.value.port
            }
          }
        }
      }
    }
  }
}

resource "azurerm_network_security_rule" "primary_nsg_outbound_rules" {
  provider = azurerm.main

  for_each = { for idx, rule in flatten([for rc in var.network_rule_collections : rc.rules]) : idx => rule }

  name                    = each.value.name
  priority                = var.nsg_base_priority + each.key
  direction               = each.value.direction
  access                  = "Allow"
  protocol                = length(each.value.protocols) > 1 && contains(each.value.protocols, "TCP") && contains(each.value.protocols, "UDP") ? "*" : title(lower(each.value.protocols[0]))
  source_port_range       = "*"
  destination_port_range  = length(each.value.destination_ports) == 1 ? each.value.destination_ports[0] : null
  destination_port_ranges = length(each.value.destination_ports) > 1 ? each.value.destination_ports : null
  source_address_prefixes = each.value.primary_region_source
  #[element(each.value.source_addresses, 0)]
  destination_address_prefix   = length(each.value.primary_region_destination) == 1 ? each.value.primary_region_destination[0] : null
  destination_address_prefixes = length(each.value.primary_region_destination) > 1 ? each.value.primary_region_destination : null
  resource_group_name          = var.primary_nsg_resource_group_name
  network_security_group_name  = var.primary_nsg_name
}

resource "azurerm_network_security_rule" "secondary_nsg_outbound_rules" {
  provider = azurerm.main

  for_each = var.deploy_secondary ? { for idx, rule in flatten([for rc in var.network_rule_collections : rc.rules]) : idx => rule } : {}

  name                         = each.value.name
  priority                     = var.nsg_base_priority + each.key
  direction                    = each.value.direction
  access                       = "Allow"
  protocol                     = length(each.value.protocols) > 1 && contains(each.value.protocols, "TCP") && contains(each.value.protocols, "UDP") ? "*" : title(lower(each.value.protocols[0]))
  source_port_range            = "*"
  destination_port_range       = length(each.value.destination_ports) == 1 ? each.value.destination_ports[0] : null
  destination_port_ranges      = length(each.value.destination_ports) > 1 ? each.value.destination_ports : null
  source_address_prefixes      = each.value.secondary_region_source
  destination_address_prefix   = length(each.value.secondary_region_destination) == 1 ? each.value.secondary_region_destination[0] : null
  destination_address_prefixes = length(each.value.secondary_region_destination) > 1 ? each.value.secondary_region_destination : null
  resource_group_name          = var.secondary_nsg_resource_group_name
  network_security_group_name  = var.secondary_nsg_name
}

resource "azurerm_network_security_rule" "primary_http_https_outbound_rule" {
  provider                    = azurerm.main
  name                        = "BaseBuild_Allow_HTTP_HTTPS_Outbound"
  priority                    = var.nsg_base_priority + 90
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["80", "443"]
  source_address_prefixes     = [var.primary_region_address]
  destination_address_prefix  = "Internet"
  resource_group_name         = var.primary_nsg_resource_group_name
  network_security_group_name = var.primary_nsg_name
}

resource "azurerm_network_security_rule" "secondary_http_https_outbound_rule" {
  provider                    = azurerm.main
  count                       = var.deploy_secondary ? 1 : 0
  name                        = "BaseBuild_Allow_HTTP_HTTPS_Outbound"
  priority                    = var.nsg_base_priority + 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["80", "443"]
  source_address_prefixes     = [var.secondary_region_address]
  destination_address_prefix  = "Internet"
  resource_group_name         = var.secondary_nsg_resource_group_name
  network_security_group_name = var.secondary_nsg_name
}
