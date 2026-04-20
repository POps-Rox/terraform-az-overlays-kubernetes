# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#------------------------------------------------------------
# Azure NoOps Naming - This should be used on all resource naming
#------------------------------------------------------------
data "popsrox_utils_resource_name" "aks" {
  name          = var.workload_name
  resource_type = "azurerm_kubernetes_cluster"
  # List of values to concanate Location & region etc.. 
  prefixes    = [var.org_name, var.use_location_short_name ? module.mod_azregions.location_short : var.location]
  suffixes    = compact([var.name_prefix == "" ? null : local.name_prefix, var.environment, local.name_suffix, var.use_naming ? "" : "aks"])
  use_slug    = var.use_naming
  clean_input = true
  separator   = "-"
}

data "popsrox_utils_resource_name" "aks_identity" {
  name          = var.workload_name
  resource_type = "azurerm_user_assigned_identity"
  prefixes      = [var.org_name, var.use_location_short_name ? module.mod_azregions.location_short : var.location]
  suffixes      = compact([var.name_prefix == "" ? null : local.name_prefix, var.environment, local.name_suffix, var.use_naming ? "" : "identity"])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}

data "popsrox_utils_resource_name" "appgw_identity" {
  name          = var.workload_name
  resource_type = "azurerm_user_assigned_identity"
  prefixes      = [var.org_name, var.use_location_short_name ? module.mod_azregions.location_short : var.location]
  suffixes      = compact([var.name_prefix == "" ? null : local.name_prefix, var.environment, local.name_suffix, var.use_naming ? "" : "identity"])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}

data "popsrox_utils_resource_name" "appgw" {
  name          = var.workload_name
  resource_type = "azurerm_application_gateway"
  prefixes      = [var.org_name, var.use_location_short_name ? module.mod_azregions.location_short : var.location]
  suffixes      = compact([var.name_prefix == "" ? null : local.name_prefix, var.environment, local.name_suffix, var.use_naming ? "" : "appgw"])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}
