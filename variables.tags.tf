# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

####################################
# Tags Configuration    ##
####################################
variable "default_tags_enabled" {
  description = "Option to enable or disable default tags."
  type        = bool
  default     = true
}

variable "add_tags" {
  description = "Map of custom tags."
  type        = map(string)
  default     = {}
}

# tflint-ignore: terraform_unused_declarations
variable "default_node_pool_tags" {
  description = "Specific tags for default node pool"
  type        = map(string)
  default     = {}
}

# tflint-ignore: terraform_unused_declarations
variable "node_pool_tags" {
  description = "Specific tags for node pool"
  type        = map(string)
  default     = {}
}

# tflint-ignore: terraform_unused_declarations
variable "aks_user_assigned_identity_tags" {
  description = "Tags to add to AKS MSI"
  type        = map(string)
  default     = {}
}

# tflint-ignore: terraform_unused_declarations
variable "aadpodidentity_extra_tags" {
  description = "Extra Tags to add to aad pod identity MSI"
  type        = map(string)
  default     = {}
}
