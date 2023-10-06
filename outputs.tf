output "user_vault_name" {
    value = azurerm_key_vault.user_vault.name
}

output "cred_vault_name" {
  value = azurerm_key_vault.credential_vault.name
}