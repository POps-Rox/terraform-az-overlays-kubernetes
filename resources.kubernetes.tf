# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.


#---------------------------------------------------------------
# Azure Kubernetes Service (AKS) Cluster
#----------------------------------------------------------------
resource "azurerm_kubernetes_cluster" "aks_cluster" {
  depends_on          = [data.azurerm_subnet.aks_subnet, azurerm_role_assignment.route_table_network_contributor]
  name                = local.cluster_name
  location            = local.location
  resource_group_name = local.resource_group_name
  kubernetes_version  = var.kubernetes_version
  node_resource_group = local.node_resource_group

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  private_cluster_enabled = true // private cluster is always enabled based on the current implementation (SCCA)
  sku_tier                = var.sku_tier
  private_dns_zone_id     = local.private_dns_zone_id
  dns_prefix              = local.dns_prefix

  network_profile {
    network_plugin = var.network_plugin
    network_policy = var.network_policy
    dns_service_ip = (var.network_profile_options == null ? null : var.network_profile_options.dns_service_ip)
    service_cidr   = (var.network_profile_options == null ? null : var.network_profile_options.service_cidr)
    outbound_type  = var.outbound_type
    pod_cidr       = (var.network_plugin == "kubenet" ? var.pod_cidr : null)
  }

  default_node_pool {
    name                         = var.default_node_pool_name
    vm_size                      = local.node_pools[var.default_node_pool_name].vm_size
    os_disk_size_gb              = local.node_pools[var.default_node_pool_name].os_disk_size_gb
    os_disk_type                 = local.node_pools[var.default_node_pool_name].os_disk_type
    auto_scaling_enabled          = local.node_pools[var.default_node_pool_name].auto_scaling_enabled
    node_count                   = (local.node_pools[var.default_node_pool_name].auto_scaling_enabled ? null : local.node_pools[var.default_node_pool_name].node_count)
    min_count                    = (local.node_pools[var.default_node_pool_name].auto_scaling_enabled ? local.node_pools[var.default_node_pool_name].min_count : null)
    max_count                    = (local.node_pools[var.default_node_pool_name].auto_scaling_enabled ? local.node_pools[var.default_node_pool_name].max_count : null)
    host_encryption_enabled       = local.node_pools[var.default_node_pool_name].host_encryption_enabled
    node_public_ip_enabled        = local.node_pools[var.default_node_pool_name].node_public_ip_enabled
    type                         = local.node_pools[var.default_node_pool_name].type
    only_critical_addons_enabled = local.node_pools[var.default_node_pool_name].only_critical_addons_enabled
    orchestrator_version         = local.node_pools[var.default_node_pool_name].orchestrator_version
    max_pods                     = local.node_pools[var.default_node_pool_name].max_pods
    node_labels                  = local.node_pools[var.default_node_pool_name].node_labels
    tags                         = local.node_pools[var.default_node_pool_name].tags
    vnet_subnet_id               = data.azurerm_subnet.aks_subnet.id #var.vnet_subnet_id

    upgrade_settings {
      max_surge = local.node_pools[var.default_node_pool_name].max_surge
    }
  }

  identity {
    type = var.identity_type

    identity_ids = (var.identity_type == "SystemAssigned" ? null :
      (var.user_assigned_identity != null ?
        [var.user_assigned_identity.id] :
    [azurerm_user_assigned_identity.aks.0.id]))
  }

  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  azure_policy_enabled = var.azure_policy_enabled

  dynamic "windows_profile" {
    for_each = local.windows_nodes ? [1] : []
    content {
      admin_username = var.windows_profile.admin_username
      admin_password = var.windows_profile.admin_password
    }
  }

  dynamic "key_vault_secrets_provider" {
    for_each = var.key_vault_secrets_provider[*]
    content {
      secret_rotation_enabled  = key_vault_secrets_provider.value.secret_rotation_enabled
      secret_rotation_interval = key_vault_secrets_provider.value.secret_rotation_interval
    }
  }

  tags = merge(local.default_tags, var.add_tags)

  lifecycle {
    ignore_changes = [
      kubernetes_version,
      tags
    ]
  }

  # Enable AD & Azure RBAC
  # azurerm 4.x: `managed` argument removed (AAD integration is always managed); `azure_rbac_enabled` is the entry point.
  azure_active_directory_role_based_access_control {
    tenant_id          = data.azurerm_subscription.current.tenant_id
    azure_rbac_enabled = true
  }


}
