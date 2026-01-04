data "azurerm_log_analytics_workspace" "mgmt" {
  name                = "law-${var.root_id}-mgmt-monitor-${var.primary_short}-001"
  resource_group_name = "rg-${var.root_id}-mgmt-monitoring-${var.primary_short}-001"
}

locals {
  tf_state = {
    ## Primary
    tf_state_primary = {
      name                = "st${var.root_id}tfstate${var.primary_short}001",
      resource_group_name = "rg-${var.root_id}-mgmt-storage-${var.primary_short}-001",
      location            = var.primary_long,
      ###VNET Configuration for Private Endpoint
      vnet_name    = "vnet-${var.root_id}-mgmt-spoke-${var.primary_short}-001",
      vnet_rg_name = "rg-${var.root_id}-mgmt-spoke-${var.primary_short}-001",
      snet_name    = "snet-mgmt-log-${var.primary_short}-001",
      #### Key Vault Configuration for CMK.
      key_vault_name     = "kv-${var.root_id}-mgmt-${var.primary_short}-001",
      key_vault_rg       = "rg-${var.root_id}-mgmt-keyvaultlz-${var.primary_short}-001",
      key_vault_key_name = "kvk-st${var.root_id}mgmtlog${var.primary_short}001",
      pe_ip              = "172.16.4.200"
      ## Required for lookups
      deploy = var.mgmt_tfstate_storage_account_primary_enabled
    }



  }
}

module "storage_account" {
  source   = "../../Modules/Storage"
  for_each = { for key, value in local.tf_state : key => value if value.deploy == true }

  providers = {
    azurerm              = azurerm
    azurerm.connectivity = azurerm.connectivity
    azurerm.management   = azurerm.management
  }

  # Storage account and location details
  st_name             = each.value["name"]
  location            = each.value["location"]
  resource_group_name = each.value["resource_group_name"]

  # Managed Identity
  managed_identity_type = "UserAssigned"

  # Storage account configuration
  account_replication_type = "GRS"

  # Log Analytics Workspace ID
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.mgmt.id

  # Root ID for the resources
  root_id = var.root_id

  # Primary and secondary short names
  primary_short = var.primary_short

  # Key Vault details
  key_vault = {
    key_vault_name     = each.value["key_vault_name"]
    resource_group     = each.value["key_vault_rg"]
    key_vault_key_name = each.value["key_vault_key_name"]
  }

  # Networking details for Private Endpoint
  pe_networking = {
    subnet_id    = each.value.location == "primary" ? module.subnet_creation["pe_subnet-primary"].subnet_id : module.subnet_creation["pe_subnet-secondary"].subnet_id
    vnet_name    = each.value["vnet_name"]
    vnet_rg_name = each.value["vnet_rg_name"]
    subnet_name  = each.value["snet_name"]
    ip           = each.value["pe_ip"]
  }

  # Tags for resource
  tags = var.management_resources_tags

  # Conditional deployment of private endpoint
  deploy_private_endpoint       = false
  public_network_access_enabled = true
  default_action                = "Allow"
  deploy_cmk                    = false
}
