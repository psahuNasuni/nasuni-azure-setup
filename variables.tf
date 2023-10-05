variable "user-vnet-name" {
  description = "Virtual Network Name for Azure Virtual Machine"
  type        = string
  default     = ""
}

variable "user_subnet_name" {
  description = "Subnet name from Virtual Network"
  type        = string
  default     = ""
}

variable "cred-vault" {
  description = "Credential Key Vault Name"
  type        = string
  default     = ""
}

variable "github-organization" {
  description = "GitHub Organization Name"
  type        = string
  default     = "psahuNasuni"
}

variable "nac-scheduler-name" {
  description = "NACScheduler VM Name"
  type        = string
}

variable "edgeappliance-resource-group" {
  description = "Resource Group Name where All Edge Resources are Provisioned"
  type        = string
}

variable "nmc-api-endpoint" {
  description = "IP Address of NMC"
  type        = string
}

variable "nmc-api-password" {
  description = "Passworf for NMC Login"
  type        = string
}

variable "nmc-api-username" {
  description = "User Name for NMC Login"
  type        = string
}

variable "user-vault-name" {
  description = "Name of User Input Key Vault"
  type        = string
  default     = ""
}

variable "product-key" {
  description = "Product Key"
  type        = string
}

variable "sp-secret" {
  description = "Application secret of the Service Principal"
  type        = string
}

variable "sp-application-id" {
  description = "Application ID of the Service Principal"
  type        = string
}

variable "use-private-ip" {
  description = "To Provision the Infrastrure in Private or Public Network"
  type        = string
  default     = "N"
}

variable "create-pem-key" {
  description = "Set to true to create a PEM key, false otherwise"
  type        = bool
  default     = false
}

variable "networking-resource-group" {
  description = "Resource Group Name where Vnet is exist"
  type        = string
}

variable "web-access-appliance-address" {
  description = "IP Address of Filer"
  type        = string
}

variable "pgp-key-path" {
  description = "Key Name with extension and location"
  type        = string
}

variable "root-user" {
  description = "Root User Name"
  type        = string
}

variable "root-password" {
  description = "Root User Password"
  type        = string
}
