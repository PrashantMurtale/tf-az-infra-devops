terraform {
  # Temporarily using local backend - uncomment below to use Azure remote state
  # backend "azurerm" {
  #   resource_group_name  = "tfstate-rg"
  #   storage_account_name = "tfstateacct123"
  #   container_name       = "tfstate"
  #   key                  = "azure-devops.tfstate"
  # }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  
  # Use variable if provided, otherwise use default from Azure CLI/credentials or ARM_SUBSCRIPTION_ID env var
  subscription_id = var.subscription_id
}
