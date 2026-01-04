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
      version = "~> 0.9.0"
    }
  }
  backend "azurerm" {


    use_azuread_auth = true
    #    use_msi          = true

  }
}
provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
  # use_msi             = true
  storage_use_azuread = true

}

provider "azurerm" {
  subscription_id = var.connectivity_subscription_id
  features {}
  alias = "connectivity"
  #use_msi = true
}
provider "azurerm" {
  subscription_id = var.management_subscription_id
  features {}
  alias = "management"
  #use_msi = true
}


provider "azapi" {
  subscription_id = var.subscription_id
  # Inherit authentication from AzureRM provider
  # The AzAPI provider will use the same Azure authentication configuration as AzureRM
  #use_msi = true
}