module "automation_account" {
  source = "../../Modules/automation_account"

  providers = {
    azurerm              = azurerm
    azurerm.connectivity = azurerm.connectivity
  }

  # Use for_each to iterate over primary and secondary deployments based on deployment flags
  for_each = merge(
    { for key, value in local.automation_account : "${key}-primary" => { location = "primary", ip1 = value.primary_ip_1, ip2 = value.primary_ip_2 } if value.deploy_primary == true },
    { for key, value in local.automation_account : "${key}-secondary" => { location = "secondary", ip1 = value.secondary_ip_1, ip2 = value.secondary_ip_2 } if value.deploy_secondary == true }
  )

  # Dynamically set values based on primary or secondary location
  automation_account_name = "aa-${var.root_id}-${var.environment}-${each.value.location == "primary" ? var.primary_short : var.secondary_short}-001"
  resource_group_name     = each.value.location == "primary" ? azurerm_resource_group.rg-primary["mgmt_RG"].name : azurerm_resource_group.rg-secondary["mgmt_RG"].name
  location                = each.value.location == "primary" ? var.primary_long : var.secondary_long
  subnet_id               = each.value.location == "primary" ? module.subnet_creation["pe_subnet-primary"].subnet_id : module.subnet_creation["pe_subnet-secondary"].subnet_id
  root_id                 = var.root_id
  virtual_network_name    = "vnet-${var.root_id}-${var.environment}-services-spoke-${each.value.location == "primary" ? var.primary_short : var.secondary_short}-001"
  vnetrg                  = "rg-${var.root_id}-${var.environment}-spoke-${each.value.location == "primary" ? var.primary_short : var.secondary_short}-001"
  tags                    = var.management_resources_tags
  private_ip1             = each.value.ip1
  private_ip2             = each.value.ip2

}
