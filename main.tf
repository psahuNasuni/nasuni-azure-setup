data "azurerm_subscription" "current" {}

data "azuread_service_principal" "current" {
  application_id = var.sp-secret
}

data "azurerm_resource_group" "vault_rg" {
  name = var.edgeappliance-resource-group
}

resource "random_id" "nac_unique_stack_id" {
  byte_length = 4
}

data "azurerm_virtual_network" "VnetToBeUsed" {
  count               = var.use-private-ip == "Y" ? 1 : 0
  name                = var.user-vnet-name
  resource_group_name = var.networking-resource-group
}

data "azurerm_subnet" "azure_subnet_name" {
  count                = var.use-private-ip == "Y" ? 1 : 0
  name                 = var.user_subnet_name
  virtual_network_name = data.azurerm_virtual_network.VnetToBeUsed[0].name
  resource_group_name  = data.azurerm_virtual_network.VnetToBeUsed[0].resource_group_name
}

data "azurerm_private_dns_zone" "storage_account_dns_zone" {
  count               = var.use_private_flow == "Y" ? 1 : 0
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = data.azurerm_virtual_network.VnetToBeUsed[0].resource_group_name
}

### Volume Storage account will be created for both Private Flow and Public Flow
resource "azurerm_storage_account" "volume_storage" {
  name                     = "nasunivolst${random_id.nac_unique_stack_id.hex}"
  resource_group_name      = data.azurerm_resource_group.vault_rg.name
  location                 = data.azurerm_resource_group.vault_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  depends_on = [
    data.azurerm_subnet.azure_subnet_name,
    data.azurerm_private_dns_zone.storage_account_dns_zone
  ]
}

resource "null_resource" "disable_storage_public_access" {
  provisioner "local-exec" {
    command = var.use_private_flow == "Y" ? "az storage account update --allow-blob-public-access false --name ${azurerm_storage_account.volume_storage.name} --resource-group ${azurerm_storage_account.volume_storage.resource_group_name}" : "echo 'INFO ::: Storage Account is Public...'"
  }
  depends_on = [azurerm_storage_account.volume_storage]
}

resource "azurerm_private_endpoint" "storage_account_private_endpoint" {
  count               = var.use_private_flow == "Y" ? 1 : 0
  name                = "nasunist${random_id.nac_unique_stack_id.hex}_private_endpoint"
  location            = azurerm_storage_account.volume_storage.location
  resource_group_name = azurerm_storage_account.volume_storage.resource_group_name
  subnet_id           = data.azurerm_subnet.azure_subnet_name[0].id

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.storage_account_dns_zone[0].id]
  }

  private_service_connection {
    name                           = "nasunist${random_id.nac_unique_stack_id.hex}_connection"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.volume_storage.id
    subresource_names              = ["blob"]
  }

  provisioner "local-exec" {
    command = "az resource wait --updated --ids ${self.subnet_id}"
  }
  depends_on = [
    data.azurerm_virtual_network.VnetToBeUsed,
    data.azurerm_subnet.azure_subnet_name,
    null_resource.disable_storage_public_access
  ]
}

resource "azurerm_storage_container" "volume_key_container" {
  name                  = "volumekeycontainer"
  storage_account_name  = azurerm_storage_account.volume_storage.name
  container_access_type = "container" # "blob" "private"
  depends_on            = [azurerm_storage_account.volume_storage]
}

resource "azurerm_storage_blob" "volume_key_blob" {
  name                   = basename(var.pgp-key-path)
  storage_account_name   = azurerm_storage_account.volume_storage.name
  storage_container_name = azurerm_storage_container.volume_key_container.name
  type                   = "Block"
  source                 = var.pgp-key-path
  depends_on             = [azurerm_storage_container.volume_key_container]
}

resource "null_resource" "pem-key-generation" {
  provisioner "local-exec" {
    command     = "chmod +x ${path.cwd}/pem-generation.sh; ${path.cwd}/./pem-generation.sh"
    interpreter = ["bash", "-c"]
  }
  provisioner "local-exec" {
    when    = destroy
    command = "rm -rf *_key.*"
  }
  depends_on = [data.azuread_service_principal.current]
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
  depends_on = [resource.null_resource.pem-key-generation,
    azurerm_storage_account.volume_storage,
    azurerm_key_vault.credential_vault
  ]
}

resource "azurerm_key_vault_secret" "azure-location" {
  name         = "azure-location"
  value        = data.azurerm_resource_group.vault_rg.location
  key_vault_id = azurerm_key_vault.user_vault.id
  depends_on   = [azurerm_key_vault.user_vault]
}

resource "azurerm_key_vault_secret" "azure-subscription" {
  name         = "azure-subscription"
  value        = data.azurerm_subscription.current.subscription_id
  key_vault_id = azurerm_key_vault.user_vault.id
  depends_on   = [azurerm_key_vault.user_vault]
}

resource "azurerm_key_vault_secret" "cred-vault" {
  name         = "cred-vault"
  value        = azurerm_key_vault.credential_vault.name
  key_vault_id = azurerm_key_vault.user_vault.id
  depends_on   = [azurerm_key_vault.user_vault]
}

resource "azurerm_key_vault_secret" "destination-container-url" {
  name         = "destination-container-url"
  value        = var.destination-container-url
  key_vault_id = azurerm_key_vault.user_vault.id
  depends_on   = [azurerm_key_vault.user_vault]
}

resource "azurerm_key_vault_secret" "github-organization" {
  name         = "github-organization"
  value        = var.github-organization
  key_vault_id = azurerm_key_vault.user_vault.id
  depends_on   = [azurerm_key_vault.user_vault]
}

resource "azurerm_key_vault_secret" "nac-scheduler-name" {
  name         = "nac-scheduler-name"
  value        = var.nac-scheduler-name
  key_vault_id = azurerm_key_vault.user_vault.id
  depends_on   = [azurerm_key_vault.user_vault]
}

resource "azurerm_key_vault_secret" "edgeappliance-resource-group" {
  name         = "edgeappliance-resource-group"
  value        = var.edgeappliance-resource-group
  key_vault_id = azurerm_key_vault.user_vault.id
  depends_on   = [azurerm_key_vault.user_vault]
}

resource "azurerm_key_vault_secret" "nmc-api-endpoint" {
  name         = "nmc-api-endpoint"
  value        = var.nmc-api-endpoint
  key_vault_id = azurerm_key_vault.user_vault.id
  depends_on   = [azurerm_key_vault.user_vault]
}

resource "azurerm_key_vault_secret" "nmc-api-password" {
  name         = "nmc-api-password"
  value        = var.nmc-api-password
  key_vault_id = azurerm_key_vault.user_vault.id
  depends_on   = [azurerm_key_vault.user_vault]
}

resource "azurerm_key_vault_secret" "nmc-api-username" {
  name         = "nmc-api-username"
  value        = var.nmc-api-username
  key_vault_id = azurerm_key_vault.user_vault.id
  depends_on   = [azurerm_key_vault.user_vault]
}

resource "azurerm_key_vault_secret" "pem-key-path" {
  name         = "pem-key-path"
  value        = var.pem-key-path
  key_vault_id = azurerm_key_vault.user_vault.id
  depends_on   = [azurerm_key_vault.user_vault]
}

resource "azurerm_key_vault_secret" "product-key" {
  name         = "product-key"
  value        = var.product-key
  key_vault_id = azurerm_key_vault.user_vault.id
  depends_on   = [azurerm_key_vault.user_vault]
}

resource "azurerm_key_vault_secret" "sp-secret" {
  name         = "sp-secret"
  value        = var.sp-secret
  key_vault_id = azurerm_key_vault.user_vault.id
  depends_on   = [azurerm_key_vault.user_vault]
}

resource "azurerm_key_vault_secret" "use-private-ip" {
  name         = "use-private-ip"
  value        = var.use-private-ip
  key_vault_id = azurerm_key_vault.user_vault.id
  depends_on   = [azurerm_key_vault.user_vault]
}

resource "azurerm_key_vault_secret" "user-vnet-name" {
  name         = "user-vnet-name"
  value        = var.user-vnet-name
  key_vault_id = azurerm_key_vault.user_vault.id
  depends_on   = [azurerm_key_vault.user_vault]
}

resource "azurerm_key_vault_secret" "networking-resource-group" {
  name         = "networking-resource-group"
  value        = var.networking-resource-group
  key_vault_id = azurerm_key_vault.user_vault.id
  depends_on   = [azurerm_key_vault.user_vault]
}

resource "azurerm_key_vault_secret" "volume-key-container-url" {
  name         = "volume-key-container-url"
  value        = azurerm_storage_blob.volume_key_blob.url
  key_vault_id = azurerm_key_vault.user_vault.id
  depends_on = [azurerm_storage_blob.volume_key_blob,
  azurerm_key_vault.user_vault]
}

resource "azurerm_key_vault_secret" "web-access-appliance-address" {
  name         = "web-access-appliance-address"
  value        = var.web-access-appliance-address
  key_vault_id = azurerm_key_vault.user_vault.id
  depends_on   = [azurerm_key_vault.user_vault]
}
############################# Provision Credential Vault ################

resource "azurerm_key_vault" "credential_vault" {
  name                       = var.cred-vault
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
}

resource "azurerm_key_vault_secret" "root_user" {
  name         = "root-user"
  value        = var.root-user
  key_vault_id = azurerm_key_vault.user_vault.id
  depends_on   = [azurerm_key_vault.credential_vault]
}

resource "azurerm_key_vault_secret" "root_password" {
  name         = "root-password"
  value        = var.root-password
  key_vault_id = azurerm_key_vault.user_vault.id
  depends_on   = [azurerm_key_vault.credential_vault]
}