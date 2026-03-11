# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

####################################
# Generic naming Configuration    ##
####################################
variable "name_prefix" {
  description = "Optional prefix for the generated name"
  type        = string
  default     = ""
}

variable "name_suffix" {
  description = "Optional suffix for the generated name"
  type        = string
  default     = ""
}

variable "use_naming" {
  description = "Use the Azure NoOps naming provider to generate default resource name. `storage_account_custom_name` override this if set. Legacy default name is used if this is set to `false`."
  type        = bool
  default     = true
}

variable "aadpodidentity_custom_name" {
  description = "Custom name for aad pod identity MSI"
  type        = string
  default     = "aad-pod-identity"
}

variable "custom_cluster_name" {
  description = "Custom cluster name"
  type        = string
  default     = ""
}

variable "aks_user_assigned_identity_custom_name" {
  description = "Custom name for the aks user assigned identity resource"
  type        = string
  default     = null
}

variable "appgw_user_assigned_identity_custom_name" {
  description = "Custom name for the application gateway user assigned identity resource"
  type        = string
  default     = null
}


variable "use_location_short_name" {
  description = "Use the short location name in the resource group name."
  type        = bool
  default     = true
}
 