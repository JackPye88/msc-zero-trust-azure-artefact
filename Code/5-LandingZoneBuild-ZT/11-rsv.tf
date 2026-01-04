module "recovery_services_vault_primary" {
  source   = "../../Modules/rsv"
  for_each = { for key, value in local.recovery_services_vault : key => value if value.deploy_primary == true }

  providers = {
    azurerm              = azurerm
    azurerm.connectivity = azurerm.connectivity
  }
  root_id              = var.root_id
  environment          = var.environment
  primary_short        = var.primary_short
  location_short       = var.primary_short
  location             = var.primary_long
  rsv_rg_name          = "mgmt" # The suffix of the resource group name for the Recovery Services Vault
  virtual_network_name = "vnet-${var.root_id}-${var.environment}-services-spoke-${var.primary_short}-001"
  subnet_name          = "snet-${var.environment}-pe-${var.primary_short}-001"
  subnet_id            = module.subnet_creation["pe_subnet-primary"].subnet_id

  management_resources_tags = var.management_resources_tags
  private_ip1               = each.value["primary_ip_1"]
  private_ip2               = each.value["primary_ip_2"]
  private_ip3               = each.value["primary_ip_3"]
  private_ip4               = each.value["primary_ip_4"]
  private_ip5               = each.value["primary_ip_5"]

}


module "recovery_services_vault_secondary" {
  source   = "../../Modules/rsv"
  for_each = { for key, value in local.recovery_services_vault : key => value if value.deploy_secondary == true }

  providers = {
    azurerm              = azurerm
    azurerm.connectivity = azurerm.connectivity
  }
  root_id        = var.root_id
  environment    = var.environment
  primary_short  = var.primary_short
  location_short = var.secondary_short
  location       = var.secondary_long

  rsv_rg_name          = "mgmt" # The suffix of the resource group name for the Recovery Services Vault
  virtual_network_name = "vnet-${var.root_id}-${var.environment}-services-spoke-${var.secondary_short}-001"
  subnet_name          = "snet-${var.environment}-pe-${var.secondary_short}-001"
  subnet_id            = module.subnet_creation["pe_subnet-secondary"].subnet_id

  management_resources_tags = var.management_resources_tags
  private_ip1               = each.value["secondary_ip_1"]
  private_ip2               = each.value["secondary_ip_2"]
  private_ip3               = each.value["secondary_ip_3"]
  private_ip4               = each.value["secondary_ip_4"]
  private_ip5               = each.value["secondary_ip_5"]

}
