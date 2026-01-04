

locals {
  subnet_name         = "snet-${var.environment}-${var.subnet_descriptor}-${var.location_short}-${var.instance}"
  resource_group_name = "rg-${var.root_id}-${var.environment}-spoke-${var.location_short}-${var.instance}"
  location            = var.location_long
  vnet_name           = "vnet-${var.root_id}-${var.environment}-${var.vnet_descriptor}-${var.location_short}-${var.instance}"
  rt_name             = "rt-snet-${var.environment}-${var.subnet_descriptor}-${var.location_short}-${var.instance}"
  nsg_name            = "nsg-snet-${var.environment}-${var.subnet_descriptor}-${var.location_short}-${var.instance}"
  route_name          = "UDR-${var.location_short}-to-${var.location_short}_firewall"
  location_no_space   = replace(var.location_long, "/\\s+/", "")
}

resource "azurerm_subnet" "Create_subnet" {
  provider = azurerm.main

  name                 = local.subnet_name
  resource_group_name  = local.resource_group_name
  virtual_network_name = local.vnet_name
  address_prefixes     = [var.subnet_address]
  # Set service endpoints, if provided
  service_endpoints                 = var.service_endpoints
  private_endpoint_network_policies = "Enabled"
  # Configure multiple service delegations
  dynamic "delegation" {
    for_each = var.service_delegation
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.name
        actions = delegation.value.actions
      }
    }
  }


  lifecycle {
    ignore_changes = [
      delegation, service_endpoints # Ignore any changes to the entire delegation block
    ]
  }
}



resource "azurerm_route_table" "rt" {
  provider = azurerm.main

  name                          = local.rt_name
  location                      = local.location
  resource_group_name           = local.resource_group_name
  bgp_route_propagation_enabled = false
  dynamic "route" {
    for_each = var.default_route_deploy ? [1] : [] # Create the route block only if route_deploy is true
    content {
      name                   = local.route_name
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = var.next_hop_address
    }
  }
  tags = merge(var.tags,
    { "creationdate" = formatdate("DD-MM-YYYY", timestamp()),
      "role"         = "Route Table"
  })
  lifecycle {
    ignore_changes = [tags["creationdate"]]
  }
}


resource "azurerm_subnet_route_table_association" "example" {
  provider = azurerm.main

  subnet_id      = azurerm_subnet.Create_subnet.id
  route_table_id = azurerm_route_table.rt.id
}



resource "azurerm_network_security_group" "nsgcreation" {
  provider = azurerm.main

  name                = local.nsg_name
  location            = local.location
  resource_group_name = local.resource_group_name
  tags = merge(var.tags,
    { "creationdate" = formatdate("DD-MM-YYYY", timestamp()),
      "role"         = "Network Security Group"
  })
  lifecycle {
    ignore_changes = [tags["creationdate"]]
  }
}



resource "azurerm_subnet_network_security_group_association" "nsgassocate" {
  provider = azurerm.main

  subnet_id                 = azurerm_subnet.Create_subnet.id
  network_security_group_id = azurerm_network_security_group.nsgcreation.id
}

resource "azurerm_network_security_rule" "denyallinbound" {
  provider = azurerm.main
  count    = var.deny_all_outbound ? 1 : 0

  name                        = "DenyAllInbound"
  priority                    = 4095
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = local.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsgcreation.name
}

resource "azurerm_network_security_rule" "denyalloutbound" {
  provider = azurerm.main
  count    = var.deny_all_outbound ? 1 : 0


  name                        = "DenyAllOutbound"
  priority                    = 4095
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = local.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsgcreation.name
}


resource "azurerm_network_watcher_flow_log" "deploy" {
  provider             = azurerm.main
  count                = var.network_watcher_flow_log ? 1 : 0
  network_watcher_name = local.location == "UK South" ? "NetworkWatcher_uksouth" : "NetworkWatcher_ukwest"
  #"NetworkWatcher_${local.location_no_space}"
  resource_group_name = "NetworkWatcherRG"
  name                = "nsg_flow_logs-${local.nsg_name}"

  network_security_group_id = azurerm_network_security_group.nsgcreation.id
  storage_account_id        = var.nsg_flow_storage_account
  enabled                   = true

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