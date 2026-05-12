##########################
# KeyVault Configuration #
##########################
variable "create_aks_keyvault" {
  description = "Controls if the keyvault should be created. If set to false, the keyvault name must be provided. Default is false."
  type        = bool
  default     = false
}

# tflint-ignore: terraform_unused_declarations
variable "key_vault_custom_name" {
  description = "Custom name for the keyvault. If not set, the name will be generated using the `org_name`, `workload_name`, `deploy_environment` and `environment` variables."
  type        = string
  default     = null
}

variable "purge_protection_enabled" {
  description = "Specifies whether protection against purge is enabled for this key vault. Default is false."
  type        = bool
  default     = false
}

variable "enabled_for_template_deployment" {
  description = "Specifies whether Azure Resource Manager is permitted to retrieve secrets from the key vault."
  type        = bool
  default     = false
}

variable "key_vault_sku_name" {
  description = "The SKU name of the Key Vault to create. Possible values are standard and premium."
  type        = string
  default     = "standard"
}

# tflint-ignore: terraform_unused_declarations
variable "virtual_network_name" {
  description = "The name of the virtual network to create the Key Vault private endpoint in."
  type        = string
  default     = null
}

# tflint-ignore: terraform_unused_declarations
variable "existing_keyvault_private_dns_zone" {
  description = "The name of the existing private DNS zone to use for the Key Vault private endpoint."
  type        = string
  default     = null
}

# tflint-ignore: terraform_unused_declarations
variable "existing_keyvault_private_subnet_name" {
  description = "The name of the existing private subnet to use for the Key Vault private endpoint."
  type        = string
  default     = null
}

variable "enable_private_endpoint" {
  description = "Controls if the enable private endpoint. If set to false, it disable private endpoint . Default is true."
  type        = bool
  default     = true
}
