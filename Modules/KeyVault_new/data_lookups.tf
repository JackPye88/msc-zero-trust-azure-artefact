data "azurerm_private_dns_zone" "dnslookup" {
  provider            = azurerm.connectivity
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = "rg-${var.root_id}-con-dns-${var.primary_region}-001"
}
data "azurerm_log_analytics_workspace" "example" {
  provider            = azurerm.management
  name                = "law-${var.root_id}-mgmt-monitor-${var.primary_region}-001"
  resource_group_name = "rg-${var.root_id}-mgmt-monitoring-${var.primary_region}-001"
}