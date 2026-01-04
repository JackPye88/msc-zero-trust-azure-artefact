module "recovery_services_vault_primary" {

  source = "../../Modules/rsv"
  #This below source shows how it can be used with a DevOps Repo.
  #source = "git::https://<ORG_NAME>@dev.azure.com/<ORG_NAME>/<DEVOPS_PROJECT_NAME>/_git/adorepo-<DEVOPS_PROJECT_NAME>-terrafrom-modules-001//rsv"
  for_each = { for key, value in local.recovery_services_vault : key => value if value.deploy_primary == true }

  providers = {
    azurerm              = azurerm
    azurerm.connectivity = azurerm.connectivity
  }
  root_id              = var.root_id
  environment          = local.environment
  primary_short        = var.primary_short
  location_short       = var.primary_short
  location             = var.primary_long
  rsv_rg_name          = "mgmt" # The suffix of the resource group name for the Recovery Services Vault
  virtual_network_name = module.vnetcreation["vnet1-primary"].vnet_name
  subnet_name          = module.subnet_creation["pe_subnet-primary"].subnet_name
  subnet_id            = module.subnet_creation["pe_subnet-primary"].subnet_id


  management_resources_tags = var.management_resources_tags
  private_ip1               = each.value["primary_ip_1"]
  private_ip2               = each.value["primary_ip_2"]
  private_ip3               = each.value["primary_ip_3"]
  private_ip4               = each.value["primary_ip_4"]
  private_ip5               = each.value["primary_ip_5"]

}


module "recovery_services_vault_secondary" {
  source = "../../Modules/rsv"
  #This below source shows how it can be used with a DevOps Repo.
  #source = "git::https://<ORG_NAME>@dev.azure.com/<ORG_NAME>/<DEVOPS_PROJECT_NAME>/_git/adorepo-<DEVOPS_PROJECT_NAME>-terrafrom-modules-001//rsv"
  for_each = { for key, value in local.recovery_services_vault : key => value if value.deploy_secondary == true }

  providers = {
    azurerm              = azurerm
    azurerm.connectivity = azurerm.connectivity
  }
  root_id              = var.root_id
  environment          = local.environment
  primary_short        = var.primary_short
  location_short       = var.secondary_short
  location             = var.secondary_long
  rsv_rg_name          = "mgmt" # The suffix of the resource group name for the Recovery Services Vault
  virtual_network_name = module.vnetcreation["vnet1-secondary"].vnet_name
  subnet_name          = module.subnet_creation["pe_subnet-secondary"].subnet_name
  subnet_id            = module.subnet_creation["pe_subnet-secondary"].subnet_id

  management_resources_tags = var.management_resources_tags
  private_ip1               = each.value["secondary_ip_1"]
  private_ip2               = each.value["secondary_ip_2"]
  private_ip3               = each.value["secondary_ip_3"]
  private_ip4               = each.value["secondary_ip_4"]
  private_ip5               = each.value["secondary_ip_5"]
}
