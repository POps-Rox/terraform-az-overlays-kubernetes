# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#---------------------------------------------------------
# Azure Region Lookup
#----------------------------------------------------------
# Azurerm provider configuration

provider "azurerm" {
  environment                = "USGovernment"
  skip_provider_registration = "true"
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azuread" {
  environment = "USGovernment"
  tenant_id   = data.azurerm_subscription.current.tenant_id
  client_id   = data.azurerm_client_config.current.client_id
}


module "mod_azure_region_lookup" {
  source = "github.com/POps-Rox/terraform-az-overlays-azregionslookup"

  azure_region = "usgovvirginia"
}

module "aks_cluster" {
  source = "../.."

  providers = {
    azurerm = azurerm
  }
  depends_on                   = [azurerm_resource_group.aks_rg, azurerm_subnet.aks_subnet]
  create_aks_resource_group    = false
  location                     = var.location
  existing_resource_group_name = azurerm_resource_group.aks_rg.name
  org_name                     = var.org_name
  deploy_environment           = var.deploy_environment
  workload_name                = var.workload_name
  environment                  = var.environment
  dns_prefix                   = "aksdns"

  azure_policy_enabled       = true
  log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id

  create_aks_keyvault = true
}

