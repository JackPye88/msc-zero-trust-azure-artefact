# Primary Resource Group
resource "azurerm_resource_group" "rg-primary" {
  for_each = { for key, value in local.lz_resource_groups : key => value if value.deploy_primary == true }
  provider = azurerm
  name     = "rg-${var.root_id}-${local.environment}-${each.value["rg_descriptor"]}-${var.primary_short}-001"
  location = var.primary_long
  tags = merge(var.management_resources_tags,
    { "creationdate" = formatdate("DD-MM-YYYY", timestamp()),
      "role"         = "Resource Group"
  })
  lifecycle {
    ignore_changes = [tags["creationdate"]]
  }
}

# Primary Delete Lock
resource "azurerm_management_lock" "rg-primary-lock" {
  for_each   = { for key, value in local.lz_resource_groups : key => value if value.deploy_primary == true && value.deploy_delete_lock_primary == true }
  name       = "${azurerm_resource_group.rg-primary[each.key].name}-delete-lock"
  scope      = azurerm_resource_group.rg-primary[each.key].id
  lock_level = "CanNotDelete"

  notes = "This lock prevents accidental deletion of the primary resource group."
}

# Secondary Resource Group
resource "azurerm_resource_group" "rg-secondary" {
  for_each = { for key, value in local.lz_resource_groups : key => value if value.deploy_secondary == true }
  provider = azurerm
  name     = "rg-${var.root_id}-${local.environment}-${each.value["rg_descriptor"]}-${var.secondary_short}-001"
  location = var.secondary_long
  tags = merge(var.management_resources_tags,
    { "creationdate" = formatdate("DD-MM-YYYY", timestamp()),
      "role"         = "Resource Group"
  })
  lifecycle {
    ignore_changes = [tags["creationdate"]]
  }
}

# Secondary Delete Lock
resource "azurerm_management_lock" "rg-secondary-lock" {
  for_each   = { for key, value in local.lz_resource_groups : key => value if value.deploy_secondary == true && value.deploy_delete_lock_secondary == true }
  name       = "${azurerm_resource_group.rg-secondary[each.key].name}-delete-lock"
  scope      = azurerm_resource_group.rg-secondary[each.key].id
  lock_level = "CanNotDelete"

  notes = "This lock prevents accidental deletion of the secondary resource group."
}