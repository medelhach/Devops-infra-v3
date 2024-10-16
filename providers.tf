terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "a60a21a6-e1d6-4313-b82a-8121eae81ea7"  # Replace with your actual subscription ID
}