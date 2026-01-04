terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.107"
    }
  }
  /* This can be enabled if required to store the terraform state in blob storage
  backend "azurerm" {
    resource_group_name  = "<Storage_account_RG>"
    storage_account_name = "<Storage_account_Name>"
    container_name       = "terraform-state"
    key                  = "initial-mgmt-build-lz.tfstate" # The state file name (stored as a blob)

    use_azuread_auth = true
    use_msi          = true

  }
  */
}

provider "azurerm" {
  subscription_id = var.management_subscription_id
  features {}
  storage_use_azuread = true
  #  use_msi = true
}
provider "azurerm" {
  subscription_id = var.identity_subscription_id
  features {}
  alias = "identity"
  #use_msi                    = true
}

provider "azurerm" {
  subscription_id = var.management_subscription_id
  features {}
  alias               = "management"
  storage_use_azuread = true
  #use_msi = true
}
provider "azurerm" {
  subscription_id = var.connectivity_subscription_id
  features {}
  alias = "connectivity"

  #use_msi = true
}
