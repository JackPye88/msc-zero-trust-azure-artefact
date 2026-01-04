
data "azurerm_private_dns_zone" "monitor" {
  provider            = azurerm.connectivity
  name                = "privatelink.monitor.azure.com"
  resource_group_name = "rg-${var.root_id}-con-dns-${var.primary_short}-001"
}

data "azurerm_private_dns_zone" "oms" {
  provider            = azurerm.connectivity
  name                = "privatelink.oms.opinsights.azure.com"
  resource_group_name = "rg-${var.root_id}-con-dns-${var.primary_short}-001"
}
data "azurerm_private_dns_zone" "ods" {
  provider            = azurerm.connectivity
  name                = "privatelink.ods.opinsights.azure.com"
  resource_group_name = "rg-${var.root_id}-con-dns-${var.primary_short}-001"
}
data "azurerm_private_dns_zone" "agentsvc" {
  provider            = azurerm.connectivity
  name                = "privatelink.agentsvc.azure-automation.net"
  resource_group_name = "rg-${var.root_id}-con-dns-${var.primary_short}-001"
}
data "azurerm_private_dns_zone" "blob" {
  provider            = azurerm.connectivity
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = "rg-${var.root_id}-con-dns-${var.primary_short}-001"
}

resource "azurerm_monitor_data_collection_endpoint" "Windows" {
  provider                      = azurerm.management
  name                          = "mdce-${var.root_id}-mgmt-monitoring-${var.primary_short}-001"
  resource_group_name           = "rg-${var.root_id}-mgmt-monitoring-${var.primary_short}-001"
  location                      = var.primary_long
  kind                          = "Windows"
  public_network_access_enabled = false
  description                   = "Windows Data Collection Endpoint"
  tags                          = var.management_resources_tags
}
/*
resource "azurerm_monitor_data_collection_endpoint" "Windows_ukw" {
  provider                      = azurerm.management
  name                          = "mdce-${var.root_id}-mgmt-monitoring-${var.secondary_short}-001"
  resource_group_name           = "rg-${var.root_id}-mgmt-monitoring-${var.secondary_short}-001"
  location                      = var.secondary_long
  kind                          = "Windows"
  public_network_access_enabled = false
  description                   = "Windows Data Collection Endpoint"
  tags                          = var.management_resources_tags
}
*/
resource "azurerm_monitor_private_link_scope" "uks" {
  name                = "ampls-${var.root_id}-mgmt-monitoring-${var.primary_short}-001"
  resource_group_name = "rg-${var.root_id}-mgmt-monitoring-${var.primary_short}-001"
  tags                = var.management_resources_tags
}

resource "azurerm_private_endpoint" "uks_private_link" {
  name                = "pe-ampls-${var.root_id}-mgmt-monitoring-${var.primary_short}-001"
  location            = var.primary_long
  resource_group_name = "rg-${var.root_id}-mgmt-monitoring-${var.primary_short}-001"
  subnet_id           = module.subnet_creation["log_subnet-primary"].subnet_id

  private_service_connection {
    name                           = "Azure_Monitor_Private_service_connection"
    private_connection_resource_id = azurerm_monitor_private_link_scope.uks.id
    is_manual_connection           = false
    subresource_names              = ["azuremonitor"]
  }

  private_dns_zone_group {
    name = "ampls"
    private_dns_zone_ids = [
      data.azurerm_private_dns_zone.monitor.id,
      data.azurerm_private_dns_zone.oms.id,
      data.azurerm_private_dns_zone.ods.id,
      data.azurerm_private_dns_zone.agentsvc.id,
      data.azurerm_private_dns_zone.blob.id
    ]
  }
}


resource "azurerm_monitor_data_collection_rule" "performance" {
  name                        = "mdcr-${var.root_id}-mgmt-monitoring-${var.primary_short}-001"
  resource_group_name         = "rg-${var.root_id}-mgmt-monitoring-${var.primary_short}-001"
  location                    = var.primary_long
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.Windows.id

  destinations {
    log_analytics {
      workspace_resource_id = var.log_analytics_workspace_id
      name                  = "law-${var.root_id}-mgmt-monitor-${var.primary_short}-001"
    }
  }

  data_flow {
    streams      = ["Microsoft-Perf", "Microsoft-InsightsMetrics"]
    destinations = ["law-${var.root_id}-mgmt-monitor-${var.primary_short}-001"]
  }


  data_sources {


    performance_counter {
      streams                       = ["Microsoft-InsightsMetrics"]
      sampling_frequency_in_seconds = 60
      counter_specifiers            = ["\\VmInsights\\DetailedMetrics"]
      name                          = "example-datasource-perfcounter"
    }


  }



  identity {
    type = "SystemAssigned"
  }

  description = "data collection rule example"
  tags        = var.management_resources_tags

}

data "azurerm_management_group" "main" {
  name = var.root_id
}

resource "azurerm_management_group_policy_assignment" "Azure_Monitor_agent" {
  name                 = "Azure Monitor Agent"
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/9575b8b7-78ab-4281-b53b-d3c1ace2260b"
  management_group_id  = data.azurerm_management_group.main.id
  display_name         = "Configure Windows machines to run Azure Monitor Agent and associate them to a Data Collection Rule"
  location             = var.primary_long
  identity {
    type = "SystemAssigned"
  }


  parameters = jsonencode({
    DcrResourceId : {
      value : azurerm_monitor_data_collection_rule.performance.id,
    },
  })

}

resource "azurerm_monitor_private_link_scoped_service" "log_analytics" {
  name                = "ampls-${var.root_id}-mgmt-monitor-${var.primary_short}-001-amplsservice"
  resource_group_name = "rg-${var.root_id}-mgmt-monitoring-${var.primary_short}-001"
  scope_name          = azurerm_monitor_private_link_scope.uks.name
  linked_resource_id  = var.log_analytics_workspace_id
}