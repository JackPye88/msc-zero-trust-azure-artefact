module "storage" {
  source = "../../Modules/Storage"

  providers = {
    azurerm              = azurerm
    azurerm.connectivity = azurerm.connectivity
    azurerm.management   = azurerm.management
  }

  # Use for_each to handle both primary and secondary configurations based on deployment flags
  for_each = merge(
    { for key, value in local.shared_storage :
      "${key}-primary" => {
        location                          = "primary",
        ip                                = value.primary_ip,
        replication_type                  = value.account_replication_type_primary,
        enable_hierarchical_namespace     = try(value.enable_hierarchical_namespace, false),
        descriptor                        = value.descriptor,
        versioning_enabled                = try(value.versioning_enabled, true),
        change_feed_enabled               = try(value.change_feed_enabled, true),
        change_feed_retention_days        = try(value.change_feed_retention_days, 14),
        blob_delete_retention_policy      = try(value.blob_delete_retention_policy, 14),
        container_delete_retention_policy = try(value.container_delete_retention_policy, 14),
        private_dns_zone                  = try(value.private_dns_zone, "privatelink.blob.core.windows.net"),
        shared_access_key_enabled         = try(value.shared_access_key_enabled, false)
    } if value.deploy_primary == true },

    { for key, value in local.shared_storage :
      "${key}-secondary" => {
        location                          = "secondary",
        ip                                = value.secondary_ip,
        replication_type                  = value.account_replication_type_secondary,
        enable_hierarchical_namespace     = try(value.enable_hierarchical_namespace, false),
        descriptor                        = value.descriptor,
        versioning_enabled                = try(value.versioning_enabled, true),
        change_feed_enabled               = try(value.change_feed_enabled, true),
        change_feed_retention_days        = try(value.change_feed_retention_days, 14),
        blob_delete_retention_policy      = try(value.blob_delete_retention_policy, 14),
        container_delete_retention_policy = try(value.container_delete_retention_policy, 14),
        private_dns_zone                  = try(value.private_dns_zone, "privatelink.blob.core.windows.net"),
        shared_access_key_enabled         = try(value.shared_access_key_enabled, false)
    } if value.deploy_secondary == true }
  )

  # Storage account name with conditional prefix based on hierarchical namespace
  st_name  = "${each.value.enable_hierarchical_namespace ? "dls" : "st"}${var.root_id}${var.environment_short}${each.value.descriptor}${each.value.location == "primary" ? var.primary_short : var.secondary_short}001"
  location = each.value.location == "primary" ? var.primary_long : var.secondary_long
  # resource_group_name = "rg-${var.root_id}-${var.environment}-storage-${each.value.location == "primary" ? var.primary_short : var.secondary_short}-001"
  resource_group_name = each.value.location == "primary" ? azurerm_resource_group.rg-primary["storage_RG"].name : azurerm_resource_group.rg-secondary["storage_RG"].name

  managed_identity_type             = "UserAssigned"
  account_replication_type          = each.value.replication_type
  log_analytics_workspace_id        = data.azurerm_log_analytics_workspace.mgmt.id
  root_id                           = var.root_id
  versioning_enabled                = each.value.versioning_enabled
  change_feed_enabled               = each.value.change_feed_enabled
  change_feed_retention_in_days     = each.value.change_feed_retention_days
  blob_delete_retention_policy      = each.value.blob_delete_retention_policy
  container_delete_retention_policy = each.value.container_delete_retention_policy
  shared_access_key_enabled         = each.value.shared_access_key_enabled
  deploy_private_endpoint           = true
  enable_hierarchical_namespace     = each.value.enable_hierarchical_namespace
  private_dns_zone                  = each.value.private_dns_zone

  primary_short = var.primary_short

  # Key Vault configuration
  key_vault = {
    key_vault_id   = each.value.location == "primary" ? module.create_kv["1-primary"].key_vault_id : module.create_kv["1-secondary"].key_vault_id
    key_vault_name = each.value.location == "primary" ? module.create_kv["1-primary"].key_vault_name : module.create_kv["1-secondary"].key_vault_name
    #resource_group = "rg-${var.root_id}-${var.environment}-kv-${each.value.location == "primary" ? var.primary_short : var.secondary_short}-001",
    resource_group = each.value.location == "primary" ? azurerm_resource_group.rg-primary["kv_RG"].name : azurerm_resource_group.rg-secondary["kv_RG"].name

    key_vault_key_name = "test"

  }

  # Private endpoint networking configuration
  pe_networking = {
    subnet_id    = each.value.location == "primary" ? module.subnet_creation["pe_subnet-primary"].subnet_id : module.subnet_creation["pe_subnet-secondary"].subnet_id
    vnet_name    = "vnet-${var.root_id}-${var.environment}-services-spoke-${each.value.location == "primary" ? var.primary_short : var.secondary_short}-001",
    vnet_rg_name = "rg-${var.root_id}-${var.environment}-spoke-${each.value.location == "primary" ? var.primary_short : var.secondary_short}-001",
    subnet_name  = each.value.location == "primary" ? module.subnet_creation["pe_subnet-primary"].subnet_name : module.subnet_creation["pe_subnet-secondary"].subnet_name
    ip           = each.value.ip
  }

  tags = var.management_resources_tags
}
