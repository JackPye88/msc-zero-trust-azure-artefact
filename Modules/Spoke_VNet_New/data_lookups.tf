data "azurerm_virtual_network" "hub" {
  provider            = azurerm.connectivity
  name                = var.hub_name
  resource_group_name = var.hub_resource_group
}