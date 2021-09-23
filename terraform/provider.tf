# Determine provider versions to be used in current folder
terraform {
  required_providers {
    azurerm = {
      version = "~> 2"
    }

    azuread = {
      version = "~> 1"
    }
  }
}

# This is required by AzureRM provider v2.0
provider "azurerm" {
  features {}

  subscription_id = "your-subscription-id-here"
}
