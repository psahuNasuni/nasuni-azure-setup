variable "user-vnet-name" {
  description = "Virtual Network Name for Azure Virtual Machine"
  type        = string
  default     = ""
}

variable "user_subnet_name" {
  description = "Subnet name, where "
  type        = string
  default     = ""
}

variable "use_private_flow" {
  description = "Use Private flow"
  type        = string
  default     = "N"
}

# variable "storage_account_name" {
#   type        = string
#   description = "Storage Account name in Azure"
#   default = ""
# }

# variable "storage_container_name" {
#   type        = string
#   description = "Storage Container name in Azure"
# }

variable "pem-key-path" {
  description = "Key Name with extension and location"
  type        = string
  default     = ""
}

variable "cred-vault" {
  type    = string
  default = ""
}

variable "destination-container-url" {
  type    = string
  default = ""
}

variable "github-organization" {
  type    = string
  default = ""
}

variable "nac-scheduler-name" {
  type    = string
  default = ""
}

variable "edgeappliance-resource-group" {
  type    = string
  default = ""
}

variable "nmc-api-endpoint" {
  type    = string
  default = ""
}

variable "nmc-api-password" {
  type    = string
  default = ""
}

variable "nmc-api-username" {
  type    = string
  default = ""
}

variable "user-vault-name" {
  type    = string
  default = ""
}

variable "product-key" {
  type    = string
  default = ""
}

variable "sp-secret" {
  type        = string
  description = "Application ID of the Service Principal user"
  default     = ""
}

variable "use-private-ip" {
  type    = string
  default = ""
}

variable "networking-resource-group" {
  type    = string
  default = ""
}

variable "volume-key-container-url" {
  type    = string
  default = ""
}

variable "web-access-appliance-address" {
  type    = string
  default = ""
}
variable "pgp-key-path" {
  description = "Key Name with extension and location"
  type        = string
  default     = ""
}
variable "root-user" {
  type    = string
  default = ""
}
variable "root-password" {
  type    = string
  default = ""
}
# variable "pgp-key" {
#   description = "Key Name with extension and location"
#   type        = string
#   default     = ""
# }