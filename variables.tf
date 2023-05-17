variable "user-vnet-name" {
  description = "Virtual Network Name for Azure Virtual Machine"
  type        = string
  default     = ""
}

variable "pem-key-path" {
  description = "Key Name with extension and location"
  type        = string
  default     = "pk-azure-key.pem"
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

variable "sp-application-id" {
  type    = string
  default = ""
}

variable "sp-secret" {
  type    = string
  default = ""
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

