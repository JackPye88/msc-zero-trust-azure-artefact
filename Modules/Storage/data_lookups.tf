
data "azurerm_private_dns_zone" "dnslookup" {
  count = var.deploy_private_endpoint ? 1 : 0 # Only deploy if enabled


  provider            = azurerm.connectivity
  name                = var.private_dns_zone
  resource_group_name = "rg-${var.root_id}-con-dns-${var.primary_short}-001"

}
