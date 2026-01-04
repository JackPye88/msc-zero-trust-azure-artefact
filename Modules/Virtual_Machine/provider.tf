# Configure the minimum required providers supported by this module
/*
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.74.0"
      configuration_aliases = [
        azurerm.main,
        azurerm.connectivity,
      ]
    
}
  }
}


*/

terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = ">= 3.84.0"
      configuration_aliases = [azurerm.main, azurerm.connectivity]
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 1.5" # Ensure you use a compatible version
    }
  }
}