resource "azurerm_resource_group" "main" {

  name     = "rg-static-prod"

  location = "East US"

}

resource "azurerm_storage_account" "website" {

  name = "jdstaticwebsite"

  resource_group_name = azurerm_resource_group.main.name

  location = azurerm_resource_group.main.location

  account_tier = "Standard"

  account_replication_type = "LRS"

  static_website {

    index_document = "index.html"

    error_404_document = "404.html"

    }
}

output "website_url" {

  value = azurerm_storage_account.website.primary_web_endpoint

}