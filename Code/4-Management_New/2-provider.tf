terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.16"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 1.5" # Ensure you use a compatible version
    }
    time = {
      source  = "hashicorp/time"
      version = "0.12.1"
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
  subscription_id = local.subscription_id
  features {}
  #  use_msi             = true
  storage_use_azuread = true
}

provider "azurerm" {
  subscription_id = var.connectivity_subscription_id
  features {}
  alias = "connectivity"
  # use_msi = true
}
provider "azurerm" {
  subscription_id = var.management_subscription_id
  features {}
  alias = "management"
  # use_msi = true
}


provider "azapi" {
  subscription_id = local.subscription_id
  # Inherit authentication from AzureRM provider
  # The AzAPI provider will use the same Azure authentication configuration as AzureRM
  # use_msi = true
}
