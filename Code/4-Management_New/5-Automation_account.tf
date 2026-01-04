module "automation_account" {
  source = "../../Modules/automation_account"
  #This below source shows how it can be used with a DevOps Repo.
  # source = "git::https://<ORG_NAME>@dev.azure.com/<ORG_NAME>/<DEVOPS_PROJECT_NAME>/_git/adorepo-<DEVOPS_PROJECT_NAME>-terrafrom-modules-001//automation_account"

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
  automation_account_name = "aa-${var.root_id}-${local.environment}-${each.value.location == "primary" ? var.primary_short : var.secondary_short}-001"
  resource_group_name     = "rg-${var.root_id}-${local.environment}-mgmt-${each.value.location == "primary" ? var.primary_short : var.secondary_short}-001"
  location                = each.value.location == "primary" ? var.primary_long : var.secondary_long
  subnet_id               = each.value.location == "primary" ? module.subnet_creation["pe_subnet-primary"].subnet_id : module.subnet_creation["pe_subnet-secondary"].subnet_id
  root_id                 = var.root_id
  virtual_network_name    = each.value.location == "primary" ? module.vnetcreation["vnet1-primary"].vnet_name : module.vnetcreation["vnet1-secondary"].vnet_name
  vnetrg                  = "rg-${var.root_id}-${local.environment}-spoke-${each.value.location == "primary" ? var.primary_short : var.secondary_short}-001"
  tags                    = var.management_resources_tags
  private_ip1             = each.value.ip1
  private_ip2             = each.value.ip2

  #depends_on = [module.subnet_creation]
}
