data "azurerm_client_config" "current" {}

data "azurerm_log_analytics_workspace" "mgmt" {
  provider            = azurerm.management
  name                = "law-${var.root_id}-mgmt-monitor-${var.primary_short}-001"
  resource_group_name = "rg-${var.root_id}-mgmt-monitoring-${var.primary_short}-001"
}

