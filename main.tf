#data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

data "azuread_service_principal" "current" {
  application_id = var.sp-application-id
}

data "azurerm_resource_group" "vault_rg" {
  name = var.edgeappliance-resource-group
}

resource "azurerm_key_vault" "user_vault" {
  name                       = var.user-vault-name
  location                   = data.azurerm_resource_group.vault_rg.location
  resource_group_name        = data.azurerm_resource_group.vault_rg.name
  tenant_id                  = data.azuread_service_principal.current.application_tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azuread_service_principal.current.application_tenant_id
    object_id = data.azuread_service_principal.current.object_id
    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "Restore",
      "Recover",
      "List",
      "Backup"
    ]
  }
  depends_on = [data.azuread_service_principal.current]
}

resource "azurerm_key_vault_secret" "azure-location" {
  name         = "azure-location"
  value        = data.azurerm_resource_group.vault_rg.location
  key_vault_id = azurerm_key_vault.user_vault.id
}

resource "azurerm_key_vault_secret" "azure-subscription" {
  name         = "azure-subscription"
  value        = data.azurerm_subscription.current.subscription_id
  key_vault_id = azurerm_key_vault.user_vault.id
}

resource "azurerm_key_vault_secret" "cred-vault" {
  name         = "cred-vault"
  value        = var.cred-vault
  key_vault_id = azurerm_key_vault.user_vault.id
}

resource "azurerm_key_vault_secret" "destination-container-url" {
  name         = "destination-container-url"
  value        = var.destination-container-url
  key_vault_id = azurerm_key_vault.user_vault.id
}

resource "azurerm_key_vault_secret" "github-organization" {
  name         = "github-organization"
  value        = var.github-organization
  key_vault_id = azurerm_key_vault.user_vault.id
}

resource "azurerm_key_vault_secret" "nac-scheduler-name" {
  name         = "nac-scheduler-name"
  value        = var.nac-scheduler-name
  key_vault_id = azurerm_key_vault.user_vault.id
}

resource "azurerm_key_vault_secret" "edgeappliance-resource-group" {
  name         = "edgeappliance-resource-group"
  value        = var.edgeappliance-resource-group
  key_vault_id = azurerm_key_vault.user_vault.id
}

resource "azurerm_key_vault_secret" "nmc-api-endpoint" {
  name         = "nmc-api-endpoint"
  value        = var.nmc-api-endpoint
  key_vault_id = azurerm_key_vault.user_vault.id
}

resource "azurerm_key_vault_secret" "nmc-api-password" {
  name         = "nmc-api-password"
  value        = var.nmc-api-password
  key_vault_id = azurerm_key_vault.user_vault.id
}

resource "azurerm_key_vault_secret" "nmc-api-username" {
  name         = "nmc-api-username"
  value        = var.nmc-api-username
  key_vault_id = azurerm_key_vault.user_vault.id
}

resource "azurerm_key_vault_secret" "pem-key-path" {
  name         = "pem-key-path"
  value        = var.pem-key-path
  key_vault_id = azurerm_key_vault.user_vault.id
}

resource "azurerm_key_vault_secret" "product-key" {
  name         = "product-key"
  value        = var.product-key
  key_vault_id = azurerm_key_vault.user_vault.id
}

resource "azurerm_key_vault_secret" "sp-secret" {
  name         = "sp-secret"
  value        = var.sp-secret
  key_vault_id = azurerm_key_vault.user_vault.id
}

resource "azurerm_key_vault_secret" "use-private-ip" {
  name         = "use-private-ip"
  value        = var.use-private-ip
  key_vault_id = azurerm_key_vault.user_vault.id
}

resource "azurerm_key_vault_secret" "user-vnet-name" {
  name         = "user-vnet-name"
  value        = var.user-vnet-name
  key_vault_id = azurerm_key_vault.user_vault.id
}

resource "azurerm_key_vault_secret" "networking-resource-group" {
  name         = "networking-resource-group"
  value        = var.networking-resource-group
  key_vault_id = azurerm_key_vault.user_vault.id
}

resource "azurerm_key_vault_secret" "volume-key-container-url" {
  name         = "volume-key-container-url"
  value        = var.volume-key-container-url
  key_vault_id = azurerm_key_vault.user_vault.id
}

resource "azurerm_key_vault_secret" "web-access-appliance-address" {
  name         = "web-access-appliance-address"
  value        = var.web-access-appliance-address
  key_vault_id = azurerm_key_vault.user_vault.id
}