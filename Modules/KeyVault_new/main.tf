data "azurerm_client_config" "current" {}



resource "azurerm_key_vault" "createkv" {
  name                          = var.kv_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  enabled_for_disk_encryption   = true
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days    = 90
  purge_protection_enabled      = true
  public_network_access_enabled = true
  enable_rbac_authorization     = true
  sku_name                      = "standard"


  tags = merge(var.tags,
    { "creationdate" = formatdate("DD-MM-YYYY", timestamp()),
      "role"         = "Azure Key Vault"
  })
  lifecycle {
    ignore_changes = [tags["creationdate"],
      network_acls[0].virtual_network_subnet_ids, access_policy

    ]
  }
  network_acls {
    default_action = "Deny"

    bypass                     = "AzureServices"
    ip_rules                   = var.ip_rules
    virtual_network_subnet_ids = var.connect_from_subnet_id != [] ? var.connect_from_subnet_id : null

  }


}




resource "azurerm_role_assignment" "kvadmin" {
  scope                = azurerm_key_vault.createkv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = var.user_object_id
}

resource "azurerm_role_assignment" "kvcontributor" {
  scope                = azurerm_key_vault.createkv.id
  role_definition_name = "Key Vault Contributor"
  principal_id         = var.user_object_id
}
resource "azurerm_private_endpoint" "kv" {
  name                = join("-", ["pe", var.kv_name])
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.subnet_id
  private_service_connection {
    name                           = join("-", ["pe", var.kv_name])
    private_connection_resource_id = azurerm_key_vault.createkv.id
    is_manual_connection           = false
    subresource_names              = ["vault"]

  }
  ip_configuration {
    name               = "ip-pe-${var.kv_name}"
    private_ip_address = var.private_ip_address
    subresource_name   = "vault"
    member_name        = "default"
  }

  private_dns_zone_group {
    name                 = "privatelink.vaultcore.azure.net"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.dnslookup.id]

  }

  ### Set Private Endpoint Tags ###
  tags = merge(var.tags,
    { "creationdate" = formatdate("DD-MM-YYYY", timestamp()),
      "role"         = "Private Endpoint"
  })
  lifecycle {
    ignore_changes = [tags["creationdate"]]
  }

}

