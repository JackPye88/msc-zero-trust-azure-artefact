data "azurerm_client_config" "current" {}

### Create User Assigned Managed Identity ###
resource "azurerm_user_assigned_identity" "uai-storage" {
  resource_group_name = var.resource_group_name
  location            = var.location

  name = join("-", ["uai", var.st_name])
}


resource "azurerm_key_vault_key" "storage-key" {
  count = var.deploy_cmk ? 1 : 0 # Only deploy if enabled

  name         = "key-${var.st_name}"
  key_vault_id = var.key_vault.key_vault_id
  key_type     = "RSA"
  key_size     = 2048



  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}



resource "azurerm_role_assignment" "storage" {
  count = var.deploy_cmk ? 1 : 0 # Only deploy if enabled

  scope                = var.key_vault.key_vault_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_user_assigned_identity.uai-storage.principal_id
}
resource "azurerm_storage_account_customer_managed_key" "storage" {
  count = var.deploy_cmk ? 1 : 0 # Only deploy if enabled

  storage_account_id        = azurerm_storage_account.storage_account.id
  key_vault_id              = var.key_vault.key_vault_id
  user_assigned_identity_id = azurerm_user_assigned_identity.uai-storage.id
  key_name                  = "key-${var.st_name}"
}


resource "azurerm_storage_account" "storage_account" {


  name                              = var.st_name
  resource_group_name               = var.resource_group_name
  location                          = var.location
  account_tier                      = var.account_tier
  account_replication_type          = var.account_replication_type
  allow_nested_items_to_be_public   = var.allow_nested_items_to_be_public
  https_traffic_only_enabled        = var.enable_https_traffic_only
  cross_tenant_replication_enabled  = var.cross_tenant_replication_enabled
  shared_access_key_enabled         = var.shared_access_key_enabled
  public_network_access_enabled     = var.public_network_access_enabled
  infrastructure_encryption_enabled = var.infrastructure_encryption_enabled
  is_hns_enabled                    = var.enable_hierarchical_namespace


  min_tls_version                 = var.min_tls_version
  default_to_oauth_authentication = true
  sas_policy {
    expiration_period = "90.00:00:00"
    expiration_action = "Log"
  }
  blob_properties {
    versioning_enabled            = var.versioning_enabled
    change_feed_enabled           = var.change_feed_enabled
    change_feed_retention_in_days = var.change_feed_retention_in_days > 0 ? var.change_feed_retention_in_days : null

    # Conditional block for delete_retention_policy
    dynamic "delete_retention_policy" {
      for_each = var.blob_delete_retention_policy > 0 ? [1] : []
      content {
        days = var.blob_delete_retention_policy
      }
    }

    # Conditional block for container_delete_retention_policy
    dynamic "container_delete_retention_policy" {
      for_each = var.container_delete_retention_policy > 0 ? [1] : []
      content {
        days = var.container_delete_retention_policy
      }
    }
  }




  ### Set the Network Rules ###

  network_rules {
    default_action = var.default_action
  }

  ### Set Managed Identity to User Assigned ####

  dynamic "identity" {
    for_each = var.managed_identity_type != null ? [1] : []
    content {
      type         = var.managed_identity_type
      identity_ids = [azurerm_user_assigned_identity.uai-storage.id]
    }
  }


  ### set the tags ###
  tags = merge(var.tags,
    { "creationdate" = formatdate("DD-MM-YYYY", timestamp()),
      "role"         = "Storage Account"
  })
  lifecycle {
    ignore_changes = [tags["creationdate"], customer_managed_key]

  }

  depends_on = [
    azurerm_user_assigned_identity.uai-storage,
  ]
}

resource "azurerm_private_endpoint" "storage_account_pe_uks" {
  count = var.deploy_private_endpoint ? 1 : 0 # Only deploy if enabled

  name                = "pe-${var.st_name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.pe_networking.subnet_id

  private_service_connection {
    name                           = "pe-${var.st_name}"
    private_connection_resource_id = azurerm_storage_account.storage_account.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }
  ip_configuration {
    name               = "ip-pe-${var.st_name}"
    private_ip_address = var.pe_networking.ip
    subresource_name   = "blob"
  }

  tags = merge(
    var.tags,
    {
      "creationdate" = formatdate("DD-MM-YYYY", timestamp())
      "Role"         = join(" ", ["Private Endpoint for", var.st_name])
    }
  )

  lifecycle {
    ignore_changes = [tags["creationdate"]]
  }

  private_dns_zone_group {
    name                 = var.private_dns_zone
    private_dns_zone_ids = [data.azurerm_private_dns_zone.dnslookup[0].id]
  }
}

