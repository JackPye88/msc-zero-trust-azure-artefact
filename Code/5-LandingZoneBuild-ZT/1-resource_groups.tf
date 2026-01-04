locals {



}





resource "azurerm_resource_group" "rg-primary" {
  for_each = { for key, value in var.lz_resource_groups : key => value if value.deploy_primary == true }
  provider = azurerm
  name     = "rg-${var.root_id}-${var.environment}-${each.value["rg_descriptor"]}-${var.primary_short}-001"
  location = var.primary_long
  tags = merge(var.management_resources_tags,
    { "creationdate" = formatdate("DD-MM-YYYY", timestamp()),
      "role"         = "Resource Group"
  })
  lifecycle {
    ignore_changes = [tags["creationdate"]]
  }

}


resource "azurerm_resource_group" "rg-secondary" {
  for_each = { for key, value in var.lz_resource_groups : key => value if value.deploy_secondary == true }
  provider = azurerm
  name     = "rg-${var.root_id}-${var.environment}-${each.value["rg_descriptor"]}-${var.secondary_short}-001"
  location = var.secondary_long
  tags = merge(var.management_resources_tags,
    { "creationdate" = formatdate("DD-MM-YYYY", timestamp()),
      "role"         = "Resource Group"
  })
  lifecycle {
    ignore_changes = [tags["creationdate"]]
  }

}