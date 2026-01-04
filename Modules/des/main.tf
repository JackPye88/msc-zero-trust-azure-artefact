data "azurerm_client_config" "current" {}




resource "azurerm_key_vault_key" "vm-key1" {
  name         = "key-des-${var.root_id}-${var.environment}-${var.location_short}-001"
  key_vault_id = var.key_vault_id
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





resource "azurerm_disk_encryption_set" "en-set1" {
  name                      = "des-${var.root_id}-${var.environment}-${var.location_short}-001"
  resource_group_name       = "rg-${var.root_id}-${var.environment}-${var.rg_descriptor}-${var.location_short}-001"
  location                  = var.location_long
  encryption_type           = "EncryptionAtRestWithPlatformAndCustomerKeys"
  key_vault_key_id          = azurerm_key_vault_key.vm-key1.versionless_id
  auto_key_rotation_enabled = true
  identity {
    type = "SystemAssigned"
  }
  tags = merge(var.tags,
    { "creationdate" = formatdate("DD-MM-YYYY", timestamp()),
      "role"         = "Disk Encryption Set"
  })
  lifecycle {
    ignore_changes = [tags["creationdate"]]
  }
}


resource "azurerm_role_assignment" "vm-disk" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_disk_encryption_set.en-set1.identity.0.principal_id
}
resource "azurerm_key_vault_access_policy" "kv-access-policy-des" {
  key_vault_id = var.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_disk_encryption_set.en-set1.identity.0.principal_id

  key_permissions = [
    "Get",
    "WrapKey",
    "UnwrapKey"
  ]
}