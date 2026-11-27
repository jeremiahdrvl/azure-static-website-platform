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

resource "azurerm_cdn_frontdoor_profile" "main" {
  name = "frontdoorprofile"
  resource_group_name = azurerm_resource_group.main.name
  sku_name = "Standard_AzureFrontDoor"
}

resource "azurerm_cdn_frontdoor_origin_group" "main" {
  name = "storage-origin-group"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
  load_balancing {}
}

resource "azurerm_cdn_frontdoor_origin" "website" {
  name = "storage-origin"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.main.id
  enabled = "true"
  host_name = azurerm_storage_account.website.primary_web_host
  http_port = 80
  https_port = 443
  origin_host_header = azurerm_storage_account.website.primary_web_host
  priority = 1
  weight = 1000
  certificate_name_check_enabled = true
}

resource "azurerm_cdn_frontdoor_endpoint" "main" {
  name = "jdfd-website-endpoint"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
}

resource "azurerm_cdn_frontdoor_route" "website" {
  name = "website-name"
  cdn_frontdoor_endpoint_id = azurerm_cdn_frontdoor_endpoint.main.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.main.id
  cdn_frontdoor_origin_ids = [azurerm_cdn_frontdoor_origin.website.id]
  enabled = "true"
  forwarding_protocol = "HttpsOnly"
  https_redirect_enabled = "true"
  patterns_to_match = ["/*"]
  supported_protocols = [
    "Http",
    "Https"
  ]
  link_to_default_domain = "true"
}

resource "azurerm_log_analytics_workspace" "main" {
  name = "Project-Logs-Workspace"
  resource_group_name = azurerm_resource_group.main.name
  location = azurerm_resource_group.main.location
  sku = "PerGB2018"
  retention_in_days = "30"
}