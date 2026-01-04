data "azurerm_subnet" "primary_bastion" {
  provider             = azurerm.connectivity
  name                 = "AzureBastionSubnet"
  virtual_network_name = "vnet-${var.root_id}-con-hub-${var.primary_short}-001"
  resource_group_name  = "rg-${var.root_id}-con-hub-${var.primary_short}-001"
  depends_on           = [module.enterprise_scale]
}

data "azurerm_virtual_network" "primary_hub" {
  provider            = azurerm.connectivity
  name                = "vnet-${var.root_id}-con-hub-${var.primary_short}-001"
  resource_group_name = "rg-${var.root_id}-con-hub-${var.primary_short}-001"
}

resource "azurerm_public_ip" "primary_bastion" {
  provider            = azurerm.connectivity
  name                = "pip-${var.root_id}-con-bas-${var.primary_short}-001"
  location            = var.primary_long
  resource_group_name = "rg-${var.root_id}-con-hub-${var.primary_short}-001"
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]
  tags = merge(var.management_resources_tags,
    { "creationdate" = formatdate("DD-MM-YYYY", timestamp()),
      "role"         = "Resource Group"
  })
  lifecycle {
    ignore_changes = [tags["creationdate"]]
  }
}

resource "azurerm_bastion_host" "primary" {
  provider            = azurerm.connectivity
  name                = "bas-${var.root_id}-hub-${var.primary_short}-001"
  location            = var.primary_long
  resource_group_name = "rg-${var.root_id}-con-hub-${var.primary_short}-001"
  sku                 = "Developer"

  virtual_network_id = data.azurerm_virtual_network.primary_hub.id


  tags = merge(var.management_resources_tags,
    { "creationdate" = formatdate("DD-MM-YYYY", timestamp()),
      "role"         = "Resource Group"
  })
  lifecycle {
    ignore_changes = [tags["creationdate"]]
  }
}



