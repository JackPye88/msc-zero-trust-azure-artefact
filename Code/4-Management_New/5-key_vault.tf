resource "time_sleep" "wait_after_kv" {
  create_duration = "300s"
  depends_on      = [module.create_kv] # Wait after VNet creation
}
resource "null_resource" "delay_execution_kv" {
  triggers = {
    wait_time = time_sleep.wait_after_kv.create_duration
  }
  depends_on = [time_sleep.wait_after_kv]
}

module "create_kv" {
  source = "../../Modules/KeyVault_new"
  #This below source shows how it can be used with a DevOps Repo.
  #source = "git::https://<ORG_NAME>@dev.azure.com/<ORG_NAME>/<DEVOPS_PROJECT_NAME>/_git/adorepo-<DEVOPS_PROJECT_NAME>-terrafrom-modules-001//KeyVault_new"

  providers = {
    azurerm              = azurerm
    azurerm.connectivity = azurerm.connectivity
    azurerm.management   = azurerm.management
  }

  # Use for_each to iterate over primary and secondary deployments in one expression
  for_each = merge(
    { for key, value in local.KeyVault : "${key}-primary" => { location = "primary", ip = value.primary_ip, identifier = value.identifier, ip_rules = try(value.ip_rules, null) } if value.deploy_primary == true },
    { for key, value in local.KeyVault : "${key}-secondary" => { location = "secondary", ip = value.secondary_ip, identifier = value.identifier, ip_rules = try(value.ip_rules, null) } if value.deploy_secondary == true }
  )

  # Dynamically set values based on primary or secondary location
  kv_name                = "kv-${var.root_id}-${local.environment}-${each.value.location == "primary" ? var.primary_short : var.secondary_short}-${each.value.identifier}"
  location               = each.value.location == "primary" ? var.primary_long : var.secondary_long
  resource_group_name    = each.value.location == "primary" ? azurerm_resource_group.rg-primary["kv_RG"].name : azurerm_resource_group.rg-secondary["kv_RG"].name
  virtual_network_name   = each.value.location == "primary" ? module.vnetcreation["vnet1-primary"].vnet_name : module.vnetcreation["vnet1-secondary"].vnet_name
  subnet_name            = each.value.location == "primary" ? module.subnet_creation["pe_subnet-primary"].subnet_name : module.subnet_creation["pe_subnet-secondary"].subnet_name
  subnet_id              = each.value.location == "primary" ? module.subnet_creation["pe_subnet-primary"].subnet_id : module.subnet_creation["pe_subnet-secondary"].subnet_id
  user_object_id         = data.azurerm_client_config.current.object_id
  shortlocation          = each.value.location == "primary" ? var.primary_short : var.secondary_short
  root_id                = var.root_id
  primary_region         = var.primary_short
  tags                   = var.management_resources_tags
  environment            = local.environment
  private_ip_address     = each.value.ip
  ip_rules               = try(length(each.value.ip_rules) > 0 ? each.value.ip_rules : null, null)
  connect_from_subnet_id = []
}