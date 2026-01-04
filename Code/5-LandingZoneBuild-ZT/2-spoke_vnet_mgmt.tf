resource "time_sleep" "wait_after_vnet" {
  create_duration = "30s"
  depends_on      = [module.vnetcreation] # Wait after VNet creation
}
resource "null_resource" "delay_execution" {
  triggers = {
    wait_time = time_sleep.wait_after_vnet.create_duration
  }
  depends_on = [time_sleep.wait_after_vnet]
}

module "vnetcreation" {
  source = "../../Modules/Spoke_VNet_New"

  providers = {
    azurerm.main         = azurerm
    azurerm.connectivity = azurerm.connectivity
  }

  # Use for_each to handle both primary and secondary configurations based on deployment flags
  for_each = merge(
    { for key, value in var.lz_spoke_vnets :
      "${key}-primary" => {
        location         = "primary",
        region_short     = var.primary_short,
        region_long      = var.primary_long,
        default_route_ip = var.primary_default_route_ip,
        vnet_descriptor  = value.vnet_descriptor,
        vnet_number      = value.vnet_number,
        vnet_address     = value.vnet_address_primary,
        deploy           = value.deploy_primary
    } if value.deploy_primary == true },

    { for key, value in var.lz_spoke_vnets :
      "${key}-secondary" => {
        location         = "secondary",
        region_short     = var.secondary_short,
        region_long      = var.secondary_long,
        default_route_ip = var.secondary_default_route_ip,
        vnet_descriptor  = value.vnet_descriptor,
        vnet_number      = value.vnet_number,
        vnet_address     = value.vnet_address_secondary,
        deploy           = value.deploy_secondary
    } if value.deploy_secondary == true }
  )

  # Dynamically assign VNET and resource group names based on primary/secondary settings
  vnet_name                              = "vnet-${var.root_id}-${var.environment}-${each.value.vnet_descriptor}-${each.value.region_short}-${each.value.vnet_number}"
  rg_name                                = each.value.location == "primary" ? azurerm_resource_group.rg-primary["spoke_RG"].name : azurerm_resource_group.rg-secondary["spoke_RG"].name
  location                               = each.value.region_long
  vnet_address                           = each.value.vnet_address
  hub_name                               = "vnet-${var.root_id}-con-hub-${each.value.region_short}-001"
  hub_resource_group                     = "rg-${var.root_id}-con-hub-${each.value.region_short}-001"
  region_short                           = each.value.region_short
  next_hop_address                       = each.value.default_route_ip
  log_analytics_workspace_id             = var.log_analytics_workspace_id
  vnetgateway_routes_enabled             = false
  log_analytics_workspace_id_workspaceid = var.log_analytics_workspace_id_workspaceid
  nsg_flow_storage_account               = "/subscriptions/${var.management_subscription_id}/resourceGroups/rg-${var.root_id}-mgmt-monitoring-${each.value.region_short}-001/providers/Microsoft.Storage/storageAccounts/st${var.root_id}mgmtlog${each.value.region_short}001"
  network_watcher_flow_log               = var.network_watcher_flow_log

  root_id     = var.root_id
  dns_servers = length(var.az_dc_ips) > 0 ? var.az_dc_ips : null
  # Set Tags
  tags = var.management_resources_tags


}
