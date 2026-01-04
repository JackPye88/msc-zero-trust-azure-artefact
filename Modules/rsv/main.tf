data "azurerm_private_dns_zone" "dnslookupblob" {
  provider            = azurerm.connectivity
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = "rg-${var.root_id}-con-dns-${var.primary_short}-001"
}
data "azurerm_private_dns_zone" "dnslookuprs" {
  provider            = azurerm.connectivity
  name                = "privatelink.siterecovery.windowsazure.com"
  resource_group_name = "rg-${var.root_id}-con-dns-${var.primary_short}-001"
}
data "azurerm_private_dns_zone" "dnslookupuks" {
  provider            = azurerm.connectivity
  name                = "privatelink.${var.location_short}.backup.windowsazure.com"
  resource_group_name = "rg-${var.root_id}-con-dns-${var.primary_short}-001"
}

resource "azurerm_recovery_services_vault" "Create" {
  name                         = "rsv-${var.root_id}-${var.environment}-backup-${var.location_short}-001"
  resource_group_name          = "rg-${var.root_id}-${var.environment}-${var.rsv_rg_name}-${var.location_short}-001"
  location                     = var.location
  sku                          = "Standard"
  cross_region_restore_enabled = true
  soft_delete_enabled          = true
  identity {
    type = "SystemAssigned"
  }
  #immutability = "Locked"
  public_network_access_enabled = false
  tags                          = var.management_resources_tags

}

resource "azurerm_private_endpoint" "recovery_services_vault_pe" {
  name                = "pe-rsv-${var.root_id}-${var.environment}-backup-${var.location_short}-001"
  resource_group_name = "rg-${var.root_id}-${var.environment}-${var.rsv_rg_name}-${var.location_short}-001"
  location            = var.location
  subnet_id           = var.subnet_id # Ensure this subnet ID is included in your local.rsv map for each vault

  private_service_connection {
    name                           = "psc-rsv-${var.root_id}-${var.environment}-backup-${var.location_short}-001"
    private_connection_resource_id = azurerm_recovery_services_vault.Create.id
    is_manual_connection           = false
    subresource_names              = ["AzureSiteRecovery"]
  }
  ip_configuration {
    name               = "ip-pe-rsv-${var.root_id}-${var.environment}-backup-${var.location_short}-001-01"
    private_ip_address = var.private_ip1
    subresource_name   = "AzureSiteRecovery"
    member_name        = "SiteRecovery-id1"
  }
  ip_configuration {
    name               = "ip-pe-rsv-${var.root_id}-${var.environment}-backup-${var.location_short}-001-02"
    private_ip_address = var.private_ip2
    subresource_name   = "AzureSiteRecovery"
    member_name        = "SiteRecovery-prot2"
  }
  ip_configuration {
    name               = "ip-pe-rsv-${var.root_id}-${var.environment}-backup-${var.location_short}-001-03"
    private_ip_address = var.private_ip3
    subresource_name   = "AzureSiteRecovery"
    member_name        = "SiteRecovery-tel1"
  }
  ip_configuration {
    name               = "ip-pe-rsv-${var.root_id}-${var.environment}-backup-${var.location_short}-001-04"
    private_ip_address = var.private_ip4
    subresource_name   = "AzureSiteRecovery"
    member_name        = "SiteRecovery-rcm1"
  }
  ip_configuration {
    name               = "ip-pe-rsv-${var.root_id}-${var.environment}-backup-${var.location_short}-001-05"
    private_ip_address = var.private_ip5
    subresource_name   = "AzureSiteRecovery"
    member_name        = "SiteRecovery-srs1"
  }
  private_dns_zone_group {
    name                 = "pdzg-rsv-${var.root_id}-${var.environment}-backup-${var.location_short}-001"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.dnslookupblob.id, data.azurerm_private_dns_zone.dnslookuprs.id, data.azurerm_private_dns_zone.dnslookupuks.id] # Ensure you have a variable or a specific ID for the private DNS zone for Recovery Services Vault
  }
}