# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#---------------------------------------------------------
# Azure Region Lookup
#----------------------------------------------------------
# Azurerm provider configuration
provider "azurerm" {
  environment                = "public"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azuread" {
  environment = "public"
  tenant_id   = data.azurerm_subscription.current.tenant_id
  client_id   = data.azurerm_client_config.current.client_id
}

module "mod_azure_region_lookup" {
  source = "github.com/POps-Rox/terraform-az-overlays-azregionslookup"

  azure_region = "eastus"
}

module "aks_cluster" {
  source = "../.."

  providers = {
    azurerm = azurerm
  }
  depends_on                   = [azurerm_resource_group.aks_rg]
  create_aks_resource_group    = false
  location                     = var.location
  existing_resource_group_name = azurerm_resource_group.aks_rg.name
  org_name                     = var.org_name
  deploy_environment           = var.deploy_environment
  workload_name                = var.workload_name
  environment                  = var.environment
  #custom_cluster_name         = "testaks"
  dns_prefix = "aksdns"

  azure_policy_enabled       = false
  log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id

  create_aks_keyvault = true

}
