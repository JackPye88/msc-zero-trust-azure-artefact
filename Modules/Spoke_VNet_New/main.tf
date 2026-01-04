locals {
  dns_zone_name = [
    "privatelink.adf.azure.com",
    "privatelink.afs.azure.net",
    "privatelink.agentsvc.azure-automation.net",
    "privatelink.analysis.windows.net",
    "privatelink.api.azureml.ms",
    "privatelink.azconfig.io",
    "privatelink.azure-api.net",
    "privatelink.azure-automation.net",
    "privatelink.azure-devices-provisioning.net",
    "privatelink.azure-devices.net",
    "privatelink.azurecr.io",
    "privatelink.azurehdinsight.net",
    "privatelink.azurehealthcareapis.com",
    "privatelink.azurestaticapps.net",
    "privatelink.azuresynapse.net",
    "privatelink.azurewebsites.net",
    "privatelink.batch.azure.com",
    "privatelink.blob.core.windows.net",
    "privatelink.cassandra.cosmos.azure.com",
    "privatelink.cognitiveservices.azure.com",
    "privatelink.database.windows.net",
    "privatelink.datafactory.azure.net",
    "privatelink.dev.azuresynapse.net",
    "privatelink.developer.azure-api.net",
    "privatelink.dfs.core.windows.net",
    "privatelink.dicom.azurehealthcareapis.com",
    "privatelink.digitaltwins.azure.net",
    "privatelink.directline.botframework.com",
    "privatelink.documents.azure.com",
    "privatelink.eventgrid.azure.net",
    "privatelink.file.core.windows.net",
    "privatelink.gremlin.cosmos.azure.com",
    "privatelink.guestconfiguration.azure.com",
    "privatelink.his.arc.azure.com",
    "privatelink.kubernetesconfiguration.azure.com",
    "privatelink.managedhsm.azure.net",
    "privatelink.mariadb.database.azure.com",
    "privatelink.media.azure.net",
    "privatelink.mongo.cosmos.azure.com",
    "privatelink.monitor.azure.com",
    "privatelink.mysql.database.azure.com",
    "privatelink.notebooks.azure.net",
    "privatelink.ods.opinsights.azure.com",
    "privatelink.oms.opinsights.azure.com",
    "privatelink.pbidedicated.windows.net",
    "privatelink.postgres.database.azure.com",
    "privatelink.prod.migration.windowsazure.com",
    "privatelink.purview.azure.com",
    "privatelink.purviewstudio.azure.com",
    "privatelink.queue.core.windows.net",
    "privatelink.redis.cache.windows.net",
    "privatelink.redisenterprise.cache.azure.net",
    "privatelink.search.windows.net",
    "privatelink.service.signalr.net",
    "privatelink.servicebus.windows.net",
    "privatelink.siterecovery.windowsazure.com",
    "privatelink.sql.azuresynapse.net",
    "privatelink.table.core.windows.net",
    "privatelink.table.cosmos.azure.com",
    "privatelink.tip1.powerquery.microsoft.com",
    "privatelink.token.botframework.com",
    "privatelink.uks.backup.windowsazure.com",
    "privatelink.ukw.backup.windowsazure.com",
    "privatelink.vaultcore.azure.net",
    "privatelink.web.core.windows.net",
    "privatelink.webpubsub.azure.com",
  ]
}

resource "azurerm_virtual_network" "VirtualNetwork" {
  provider            = azurerm.main
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.rg_name
  address_space       = [var.vnet_address]

  tags = merge(var.tags,
    { "creationdate" = formatdate("DD-MM-YYYY", timestamp()),
      "role"         = "Virtual Network"
  })
  lifecycle {
    ignore_changes = [tags["creationdate"]]
  }
}

resource "azurerm_virtual_network_dns_servers" "virtual_network" {
  count              = length(var.dns_servers) > 0 ? 1 : 0
  virtual_network_id = azurerm_virtual_network.VirtualNetwork.id
  dns_servers        = var.dns_servers
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  provider                     = azurerm.connectivity
  name                         = join("-", ["peer", var.hub_name, var.vnet_name])
  resource_group_name          = var.hub_resource_group
  virtual_network_name         = var.hub_name
  remote_virtual_network_id    = azurerm_virtual_network.VirtualNetwork.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = var.vnetgateway_routes_enabled
  depends_on                   = [azurerm_virtual_network.VirtualNetwork]
}
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  provider                     = azurerm.main
  name                         = join("-", ["peer", var.vnet_name, var.hub_name])
  resource_group_name          = var.rg_name
  virtual_network_name         = var.vnet_name
  remote_virtual_network_id    = data.azurerm_virtual_network.hub.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = var.vnetgateway_routes_enabled
  depends_on                   = [azurerm_virtual_network.VirtualNetwork]
}

resource "azurerm_route" "ER_To_Firewall" {
  provider               = azurerm.connectivity
  count                  = var.vnetgateway_routes_enabled ? 1 : 0
  name                   = "UDR-VPN-To-${var.region_short}Firewall${var.vnet_name}"
  resource_group_name    = "rg-${var.root_id}-con-hub-${var.region_short}-001"
  route_table_name       = "rt-con-gatewaysubnet-${var.region_short}-001"
  address_prefix         = var.vnet_address
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.next_hop_address


}

/*
resource "azurerm_private_dns_zone_virtual_network_link" "private_link_azure_container_reg" {
  name                  = join("-",["dns_link_privatelink_azurecr-to",var.vnet_name])
  resource_group_name   = var.hub_resource_group
  private_dns_zone_name = "privatelink.azurecr.io"
  virtual_network_id    = azurerm_virtual_network.VirtualNetwork.id
  depends_on = [azurerm_virtual_network.VirtualNetwork]
}

resource "azurerm_private_dns_zone_virtual_network_link" "azure_container_reg" {
  name                  = join("-",["dns_link_azurecr-to",var.vnet_name])
  resource_group_name   = var.hub_resource_group
  private_dns_zone_name = "azurecr.io"
  virtual_network_id    = azurerm_virtual_network.VirtualNetwork.id
  depends_on = [azurerm_virtual_network.VirtualNetwork]
}

resource "azurerm_private_dns_zone_virtual_network_link" "azure_pl_vault_reg" {
  name                  = join("-",["dns_link_privatelink.vaultcore.azure.net-to",var.vnet_name])
  resource_group_name   = var.hub_resource_group
  private_dns_zone_name = "privatelink.vaultcore.azure.net"
  virtual_network_id    = azurerm_virtual_network.VirtualNetwork.id
  depends_on = [azurerm_virtual_network.VirtualNetwork]
}


resource "azurerm_private_dns_zone_virtual_network_link" "private_link_azure_pl_blob" {
  name                  = join("-",["dns_link_privatelink.blob.core.windows.net-to",var.vnet_name])
  resource_group_name   = var.hub_resource_group
  private_dns_zone_name = "privatelink.blob.core.windows.net"
  virtual_network_id    = azurerm_virtual_network.VirtualNetwork.id
  depends_on = [azurerm_virtual_network.VirtualNetwork]
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_link_azure_pl_sql" {
  name                  = join("-",["dns_link_privatelink.database.windows.net-to",var.vnet_name])
  resource_group_name   = var.hub_resource_group
  private_dns_zone_name = "privatelink.database.windows.net"
  virtual_network_id    = azurerm_virtual_network.VirtualNetwork.id
  depends_on = [azurerm_virtual_network.VirtualNetwork]
}



### Logging to Log Analytics Workspace ###

resource "azurerm_monitor_diagnostic_setting" "VirtualNetwork" {
  name               = join("-",["diag",var.vnet_name,"to_log-prod-uks-001"])
  target_resource_id = azurerm_virtual_network.VirtualNetwork.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  log {
    category = "VMProtectionAlerts"
    enabled  = true
  }
   
  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  }
}
*/


resource "azurerm_network_watcher_flow_log" "deploy" {
  provider             = azurerm.main
  count                = var.network_watcher_flow_log ? 1 : 0
  network_watcher_name = var.location == "UK South" ? "NetworkWatcher_uksouth" : "NetworkWatcher_ukwest"
  #"NetworkWatcher_${local.location_no_space}"
  resource_group_name = "NetworkWatcherRG"
  name                = "nsg_flow_logs-${azurerm_virtual_network.VirtualNetwork.name}"

  target_resource_id = azurerm_virtual_network.VirtualNetwork.id
  storage_account_id = var.nsg_flow_storage_account
  enabled            = true

  retention_policy {
    enabled = true
    days    = 14
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = var.log_analytics_workspace_id_workspaceid
    workspace_region      = "UK South"
    workspace_resource_id = var.log_analytics_workspace_id
    interval_in_minutes   = 10
  }
}