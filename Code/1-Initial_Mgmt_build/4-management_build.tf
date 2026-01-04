# Get the current client configuration from the AzureRM provider.
# This is used to populate the root_parent_id variable with the
# current Tenant ID used as the ID for the "Tenant Root Group"
# Management Group.

data "azurerm_client_config" "core" {}

# Declare the Azure landing zones Terraform module
# and provide a base configuration.

module "enterprise_scale" {
  source  = "Azure/caf-enterprise-scale/azurerm"
  version = "6.1.0" # change this to your desired version, https://www.terraform.io/language/expressions/version-constraints

  default_location = "UKSouth"

  providers = {
    azurerm              = azurerm
    azurerm.connectivity = azurerm
    azurerm.management   = azurerm
  }

  root_parent_id = data.azurerm_client_config.core.tenant_id
  root_id        = var.root_id
  root_name      = var.root_name
  library_path   = "${path.root}/lib"


  deploy_management_resources    = var.deploy_management_resources
  subscription_id_management     = var.management_subscription_id
  configure_management_resources = local.configure_management_resources
  #depends_on = [azurerm_resource_group.rg-mgmt-uks-001]
  deploy_identity_resources    = true
  subscription_id_identity     = var.identity_subscription_id
  configure_identity_resources = local.configure_identity_resources


  archetype_config_overrides = {

    identity = {
      archetype_id = "es_identity"
      parameters = {
        Deny-Subnet-Without-Nsg = {
          effect = "Audit"
        }

      }
      access_control = {}
    }

    landing-zones = {
      archetype_id = "es_landing_zones"
      parameters = {
        Deny-Subnet-Without-Nsg = {
          Effect = "Audit"
        }
      }
      "Enforce-GR-KeyVault" = {
        keyVaultIntegratedCa    = "Audit"
        keyVaultNonIntegratedCa = "Audit"
        secretsActiveInDays     = 110
        secretsValidityInDays   = 180
        "secretsValidPeriod"    = "Audit"
      }
      access_control = {}
    }

    sandboxes = {
      archetype_id = "es_sandboxes"
      parameters = {
        Enforce-ALZ-Sandbox = {
          effectDenyVnetPeering = "Audit"
        }
      }

      access_control = {}
    }



  }
}



