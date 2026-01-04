resource "azurerm_automation_account" "create" {
  name                = var.automation_account_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Basic"

  # Enable system-assigned managed identity
  identity {
    type = "SystemAssigned"
  }

  # Disable public network access
  public_network_access_enabled = false

  tags = merge(var.tags,
    { "creationdate" = formatdate("DD-MM-YYYY", timestamp()),
      "role"         = "Automation Account"
  })
  lifecycle {
    ignore_changes = [tags["creationdate"]]
  }

}

resource "azurerm_private_endpoint" "aa" {
  name                = join("-", ["pe", var.automation_account_name])
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.subnet_id
  private_service_connection {
    name                           = join("-", ["pe", var.automation_account_name])
    private_connection_resource_id = azurerm_automation_account.create.id
    is_manual_connection           = false
    subresource_names              = ["DSCAndHybridWorker"]

  }

  private_dns_zone_group {
    name                 = "privatelink.azure-automation.net"
    private_dns_zone_ids = [local.dns_lookup_id]

  }
  ip_configuration {
    name               = "ip-pe-${var.automation_account_name}-01"
    private_ip_address = var.private_ip1
    subresource_name   = "DSCAndHybridWorker"
    member_name        = "AgentService"
  }
  ip_configuration {
    name               = "ip-pe-${var.automation_account_name}-02"
    private_ip_address = var.private_ip2
    subresource_name   = "DSCAndHybridWorker"
    member_name        = "JRDS"
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



data "azurerm_private_dns_zone" "dnslookup" {
  provider            = azurerm.connectivity
  name                = "privatelink.azure-automation.net"
  resource_group_name = "rg-${var.root_id}-con-dns-uks-001"
}
locals {
  dns_lookup_id = data.azurerm_private_dns_zone.dnslookup.id
}