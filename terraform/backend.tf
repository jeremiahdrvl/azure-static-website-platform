terraform {

  backend "azurerm" {

    resource_group_name  = "rg-tfstate"

    storage_account_name = "jdstaticwebplatform"

    container_name       = "tfstate"

    key                  = "staticwebsite.tfstate"

  }
}