data "azurerm_firewall_policy" "example" {
  provider            = azurerm.connectivity
  name                = "afwpol-${var.root_id}-con-hub-${var.primary_short}-001"
  resource_group_name = "rg-${var.root_id}-con-hub-${var.primary_short}-001"
}


locals {
  activedirectory_primary_snet_enabled   = true
  activedirectory_secondary_snet_enabled = false
  log_primary_ip_address                 = "172.10.10.10"

  nrc_name = "${var.environment}-virtualmachines"
  #identity_destination = flatten([local.activedirectory_primary_snet_enabled ? var.dc_primary_ip : "", local.activedirectory_secondary_snet_enabled ? var.dc_secondary_ip : "", local.on_prem_dc_ips])
  identity_destination = compact(concat(local.activedirectory_primary_snet_enabled ? [var.dc_primary_ip] : [], local.activedirectory_secondary_snet_enabled ? [var.dc_secondary_ip] : [], var.on_prem_dc_ips))
  azdcips              = compact(concat(local.activedirectory_primary_snet_enabled ? [var.dc_primary_ip] : [], local.activedirectory_secondary_snet_enabled ? [var.dc_secondary_ip] : [], ))
  primazdcip           = compact(concat(local.activedirectory_primary_snet_enabled ? [var.dc_primary_ip] : []))
  secazdcip            = compact(concat(local.activedirectory_secondary_snet_enabled ? [var.dc_secondary_ip] : []))
  all_networks         = compact(concat(tolist([var.azure_all_networks]), var.on_prem_networks))
  all_networks_string  = join(", ", local.all_networks)

  basebuilds = [
    {
      name            = "rcg_${var.environment}_virtual_machines-basebuild"
      rule_descriptor = "${var.environment}_Virtual_Machines"
      prod_source_address = compact(
        concat(
          [local.lz_spoke_subnets.vm_subnet.deploy_primary ? local.lz_spoke_subnets.vm_subnet.subnet_address_primary : ""],
          local.lz_spoke_subnets.vm_subnet.deploy_secondary ? [local.lz_spoke_subnets.vm_subnet.subnet_address_secondary] : []
        )
      )
      primary_region_address            = local.lz_spoke_subnets.vm_subnet.deploy_primary ? local.lz_spoke_subnets.vm_subnet.subnet_address_primary : null
      secondary_region_address          = local.lz_spoke_subnets.vm_subnet.deploy_secondary ? local.lz_spoke_subnets.vm_subnet.subnet_address_secondary : null
      primary_nsg_name                  = "nsg-snet-${var.environment}-virtualmachines-uks-001"
      secondary_nsg_name                = "nsg-snet-${var.environment}-virtualmachines-ukw-001"
      primary_nsg_resource_group_name   = "rg-${var.root_id}-${var.environment}-spoke-uks-001"
      secondary_nsg_resource_group_name = "rg-${var.root_id}-${var.environment}-spoke-ukw-001"
      Firewall_priority                 = "1200"
      nsg_base_priority                 = "1300"
      deploy                            = true
      deploy_secondary                  = false
      custom_network_rules = [
      ]
    }

  ]
  network_rule_collections_template = [
    { name = "BaseBuild_CHANGEME_To_AZ_DC_TCP_UDP", fw_deploy = true, direction = "Outbound", protocols = ["TCP", "UDP"], destination_ports = ["123", "135", "137", "139", "445", "389", "636", "3268", "3269", "88", "53", "42", "1512"], destination_addresses = local.identity_destination },
    { name = "BaseBuild_CHANGEME_To_AZ_DC_UDP", fw_deploy = true, direction = "Outbound", protocols = ["UDP"], destination_ports = ["138"], destination_addresses = local.identity_destination },
    { name = "BaseBuild_CHANGEME_To_AZ_DC_TCP", fw_deploy = true, direction = "Outbound", protocols = ["TCP"], destination_ports = ["49152-65535"], destination_addresses = local.identity_destination },
    { name = "BaseBuild_CHANGEME__to_KMS", fw_deploy = true, direction = "Outbound", protocols = ["TCP"], destination_ports = ["1688"], destination_addresses = ["20.118.99.224", "40.83.235.53", "23.102.135.246", "172.22.251.85"] },
    { name = "BaseBuild_CHANGEME_To_ASR_Cache", fw_deploy = true, direction = "Outbound", protocols = ["TCP"], destination_ports = ["443"], destination_addresses = [local.asr_cache.Base.primary_ip, local.asr_cache.Base.secondary_ip, "172.16.4.128/26", "172.16.132.128/26"] },
    { name = "BaseBuild_CHANGEME_To_Log_Analytics", fw_deploy = true, direction = "Outbound", protocols = ["TCP"], destination_ports = ["443"], destination_addresses = [local.log_primary_ip_address, "172.16.4.69", "172.16.4.70", "172.16.4.71", "172.16.4.72", "172.16.4.73", "172.16.4.74", "172.16.4.75", "172.16.4.76", "172.16.4.77", "172.16.4.78", "172.16.4.79", "172.16.4.80", "172.16.4.81", "172.16.4.82"] }

  ]

  application_rule_collections_template = [
    { name = "Allow HTTP & HTTPS Outbound", destination_fqdns = ["*"], protocols = [{ type = "Http", port = 80 }, { type = "Https", port = 443 }] }
  ]
}


module "nsgs" {
  for_each = { for bb in local.basebuilds : bb.name => bb if bb.deploy }

  source = "../../modules/test module"
  providers = {
    azurerm.connectivity = azurerm.connectivity
    azurerm.main         = azurerm
  }

  name                              = each.value.name
  priority                          = each.value.nsg_base_priority
  firewall_policy_id                = data.azurerm_firewall_policy.example.id
  rule_descriptor                   = each.value.rule_descriptor
  primary_nsg_name                  = each.value.primary_nsg_name
  secondary_nsg_name                = each.value.secondary_nsg_name
  primary_nsg_resource_group_name   = each.value.primary_nsg_resource_group_name
  secondary_nsg_resource_group_name = each.value.secondary_nsg_resource_group_name
  #firewall_priority = each.value.Firewall_priority
  nsg_base_priority        = each.value.nsg_base_priority
  deploy_secondary         = each.value.deploy_secondary
  primary_region_address   = each.value.primary_region_address
  secondary_region_address = each.value.secondary_region_address
  azure_all_networks       = var.azure_all_networks
  on_prem_networks         = var.on_prem_networks


  network_rule_collections = [{
    name     = "rc-${each.value.rule_descriptor}-basebuild-net"
    priority = each.value.Firewall_priority + 25
    action   = "Allow"
    rules = concat(
      [for rule in local.network_rule_collections_template : merge(rule, { source_addresses = each.value.prod_source_address, primary_region_source = [each.value.primary_region_address], secondary_region_source = [each.value.secondary_region_address], primary_region_destination = rule.destination_addresses, secondary_region_destination = rule.destination_addresses, name = replace(rule.name, "CHANGEME", each.value.rule_descriptor) })],
      each.value.custom_network_rules
    )
  }]

  application_rule_collections = [{
    name     = "rc-${each.value.rule_descriptor}-basebuild-net-app"
    priority = each.value.Firewall_priority + 50
    action   = "Allow"
    rules    = [for rule in local.application_rule_collections_template : merge(rule, { source_addresses = each.value.prod_source_address })]
  }]

}
