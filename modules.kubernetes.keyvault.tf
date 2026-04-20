# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

module "mod_key_vault" {
  depends_on = [
    azurerm_user_assigned_identity.aks
  ]
  source = "github.com/POps-Rox/tf-az-overlays-keyvault"
  count  = var.create_aks_keyvault ? 1 : 0
  providers = {
    azurerm     = azurerm
    azurerm.hub = azurerm
  }
  existing_resource_group_name = local.resource_group_name
  location                     = local.location
  environment                  = var.environment
  deploy_environment           = var.deploy_environment
  org_name                     = var.org_name
  workload_name                = var.workload_name

  # Key Vault Configuration
  sku_name                = var.key_vault_sku_name
  enable_purge_protection = var.purge_protection_enabled
  enabled_for_deployment  = var.enabled_for_template_deployment

  # Creating Private Endpoint requires, VNet name to create a Private Endpoint
  # By default this will create a `privatelink.vaultcore.azure.net` DNS zone. if created in commercial cloud
  # To use existing subnet, specify `existing_private_subnet_name` with valid subnet name. 
  # To use existing private DNS zone specify `existing_private_dns_zone` with valid zone name.

  enable_private_endpoint       = var.enable_private_endpoint
  existing_virtual_network_name = data.azurerm_virtual_network.aks_vnet.name
  existing_private_subnet_name  = data.azurerm_subnet.aks_subnet.name

  # This is to enable resource locks for the key vault. 
  enable_resource_locks = var.enable_resource_locks

  # Tags for Azure Resources
  add_tags = merge(var.add_tags, local.default_tags)
}

# Create Access Policy for API Service Identity. This is a workaround for the bug in the POps-Rox/overlays-key-vault/azurerm module
resource "azurerm_key_vault_access_policy" "aks_access_policy" {
  depends_on = [
    module.mod_key_vault,
    azurerm_user_assigned_identity.aks
  ]
  count        = var.create_aks_keyvault && var.identity_type == "UserAssigned" ? 1 : 0
  key_vault_id = module.mod_key_vault.0.key_vault_id
  tenant_id    = data.azurerm_subscription.current.tenant_id
  object_id    = azurerm_kubernetes_cluster.aks_cluster.kubelet_identity.0.object_id


  key_permissions = [
    "Get",
  ]

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete"
  ]
}
