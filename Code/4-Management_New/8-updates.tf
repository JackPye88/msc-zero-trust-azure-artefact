
# ✅ Step 1: Retrieve All Subscriptions in the Tenant
data "azurerm_subscriptions" "all" {}

# ✅ Step 2: Create Maintenance Configurations
resource "azurerm_maintenance_configuration" "maintenance_configs" {
  provider            = azurerm.management
  for_each            = local.maintenance_configs
  name                = "mc-${var.root_id}-mgmt-${each.key}-${var.primary_short}-001"
  resource_group_name = "rg-${var.root_id}-mgmt-mgmt-${var.primary_short}-001"
  location            = var.primary_long
  scope               = "InGuestPatch"

  window {
    start_date_time = "2023-12-14 ${each.value.start_time}"
    duration        = "04:00"
    time_zone       = "GMT Standard Time"
    recur_every     = each.value.recur_every
  }

  in_guest_user_patch_mode = "User"

  install_patches {
    reboot = "IfRequired"
    windows {
      classifications_to_include = [
        "Critical", "Security",
      ]
    }
  }

  tags = var.management_resources_tags
}

# ✅ Step 3: Assign Maintenance Configuration to VMs Based on PatchGroup Tag
resource "azurerm_maintenance_assignment_dynamic_scope" "vm_maintenance" {
  for_each                     = local.maintenance_configs
  name                         = "update-assignment-${each.key}"
  maintenance_configuration_id = azurerm_maintenance_configuration.maintenance_configs[each.key].id
  provider                     = azurerm.management

  filter {
    tags {
      tag    = "PatchGroup"
      values = [each.value.tag_value]
    }
  }
}

# ✅ Step 4: Create a Loop Over All Subscription & Maintenance Configurations
locals {
  subscription_maintenance_combinations = flatten([
    for sub in data.azurerm_subscriptions.all.subscriptions : [
      for config_key, config_value in local.maintenance_configs : {
        subscription_id = sub.subscription_id
        display_name    = sub.display_name
        config_key      = config_key
        tag_value       = config_value.tag_value
      }
    ]
  ])
}

# ✅ Step 5: Assign Maintenance Configuration to ALL Subscriptions
resource "azapi_resource" "update_configuration_assignments" {
  for_each  = { for item in local.subscription_maintenance_combinations : "${item.subscription_id}-${item.config_key}" => item }
  type      = "Microsoft.Maintenance/configurationAssignments@2023-04-01"
  location  = "global"
  parent_id = "/subscriptions/${each.value.subscription_id}" # Assign to each subscription

  name = "assignment-${each.value.display_name}-${each.value.config_key}" # ✅ Unique Name for Each Assignment

  schema_validation_enabled = false # ✅ Bypass outdated schema validation

  body = jsonencode({
    properties = {
      maintenanceConfigurationId = azurerm_maintenance_configuration.maintenance_configs[each.value.config_key].id

      filter = {
        tagSettings = {          # ✅ Corrected structure for tagSettings
          filterOperator = "Any" # Example operator
          tags = {
            AZUpdate = [each.value.tag_value] # Corrected tags structure
          }
        }
      }
    }
  })
}