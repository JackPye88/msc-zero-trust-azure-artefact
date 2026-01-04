
module "subnet_creation" {
  source = "../../Modules/spoke_subnet"
  #This below source shows how it can be used with a DevOps Repo.
  # source = "git::https://<ORG_NAME>@dev.azure.com/<ORG_NAME>/<DEVOPS_PROJECT_NAME>/_git/adorepo-<DEVOPS_PROJECT_NAME>-terrafrom-modules-001//spoke_subnet"

  providers = {
    azurerm.main = azurerm
  }

  # Combined for_each for both primary and secondary configurations
  for_each = merge(
    { for key, value in local.lz_spoke_subnets :
      "${key}-primary" => {
        location_short       = var.primary_short,
        location_long        = var.primary_long,
        subnet_address       = value.subnet_address_primary,
        subnet_descriptor    = value.subnet_descriptor
        vnet_descriptor      = value.vnet_descriptor
        next_hop_address     = var.primary_default_route_ip,
        service_endpoints    = try(value.service_endpoints, []),
        service_delegation   = try(value.service_delegation, []),
        deny_all_outbound    = try(value.deny_all_outbound, true)
        default_route_deploy = try(value.default_route_deploy, true)

    } if value.deploy_primary == true },

    { for key, value in local.lz_spoke_subnets :
      "${key}-secondary" => {
        location_short       = var.secondary_short,
        location_long        = var.secondary_long,
        subnet_address       = value.subnet_address_secondary,
        subnet_descriptor    = value.subnet_descriptor
        vnet_descriptor      = value.vnet_descriptor
        next_hop_address     = var.secondary_default_route_ip,
        service_endpoints    = try(value.service_endpoints, []),
        service_delegation   = try(value.service_delegation, []),
        deny_all_outbound    = try(value.deny_all_outbound, true)
        default_route_deploy = try(value.default_route_deploy, true)

    } if value.deploy_secondary == true }
  )

  environment                = local.environment
  subnet_descriptor          = each.value.subnet_descriptor
  vnet_descriptor            = each.value.vnet_descriptor
  location_short             = each.value.location_short
  location_long              = each.value.location_long
  subnet_address             = each.value.subnet_address
  next_hop_address           = each.value.next_hop_address
  root_id                    = var.root_id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  #log_analytics_workspace_id_workspaceid = var.log_analytics_workspace_id_workspaceid
  #nsg_flow_storage_account               = "/subscriptions/${var.management_subscription_id}/resourceGroups/rg-${var.root_id}-mgmt-monitoring-${each.value.location_short}-001/providers/Microsoft.Storage/storageAccounts/st${var.root_id}mgmtlog${each.value.location_short}001"
  deny_all_outbound    = each.value.deny_all_outbound
  default_route_deploy = each.value.default_route_deploy

  # Optional attributes with try defaults
  service_endpoints  = each.value.service_endpoints
  service_delegation = each.value.service_delegation

  #### Set Tags #####
  #network_watcher_flow_log = var.network_watcher_flow_log
  tags = var.management_resources_tags

  depends_on = [null_resource.delay_execution] # Ensures execution order

}
