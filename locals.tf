# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

locals {

  user_assigned_identity_name = (var.user_assigned_identity_name == null ? "aks-${local.cluster_name}-control-plane" : var.user_assigned_identity_name)

  aks_identity_id = (var.identity_type == "SystemAssigned" ? azurerm_kubernetes_cluster.aks_cluster.identity[0].principal_id :
  (var.user_assigned_identity == null ? azurerm_user_assigned_identity.aks[0].principal_id : var.user_assigned_identity.principal_id))

  node_resource_group = (var.node_resource_group != null ? var.node_resource_group : "MC-${local.cluster_name}")

  dns_prefix          = var.dns_prefix
  private_dns_zone_id = var.private_dns_zone_id


  node_pools            = zipmap(keys(var.node_pools), [for node_pool in values(var.node_pools) : merge(var.node_pool_defaults, node_pool)])
  additional_node_pools = { for k, v in local.node_pools : k => v if k != var.default_node_pool_name }

  windows_nodes = (length([for v in local.node_pools : v if lower(v.os_type) == "windows"]) > 0 ? true : false)

  api_server_authorized_ip_ranges = (var.api_server_authorized_ip_ranges == null ? null : values(var.api_server_authorized_ip_ranges))

  # Defaults for Linux profile
  # Generally smaller images so can run more pods and require smaller HD
  default_linux_node_profile = {
    max_pods        = 30
    os_disk_size_gb = 128
  }

  # Defaults for Windows profile
  # Do not want to run same number of pods and some images can be quite large
  default_windows_node_profile = {
    max_pods        = 20
    os_disk_size_gb = 256
  }

  /* invalid_node_pool_attributes = join(",", flatten([for np in values(var.node_pools) : [for k, v in np : k if !(contains(keys(var.node_pool_defaults), k))]]))
  validate_node_pool_attributes = (length(local.invalid_node_pool_attributes) > 0 ?
  file("ERROR: invalid node pool attribute:  ${local.invalid_node_pool_attributes}") : null)

  validate_node_resource_group_length = (length(local.node_resource_group) > 80 ?
  file("Error: node resource group length exceeds maximium allowed (80 characters)") : null)

  validate_windows_config = (local.windows_nodes && var.windows_profile == null ?
  file("ERROR: windows node pools require a windows_profile") : null)

  validate_virtual_network_support = (var.identity_type == "SystemAssigned" && var.virtual_network != null ?
  file("ERROR: virtual network unavailable with SystemAssigned identity type") : null)

  validate_multiple_node_pools = (((local.node_pools[var.default_node_pool_name].type != "VirtualMachineScaleSets") && (length(local.additional_node_pools) > 0)) ?
  file("ERROR: multiple node pools only allowed when default node pool type is VirtualMachineScaleSets") : null)

  validate_default_node_pool_name = (lower(local.node_pools[var.default_node_pool_name].os_type) != "linux" ?
  file("ERROR: default node pool type must be Linux") : null)

  validate_cluster_name = ((var.cluster_name == null) ?
  file("ERROR: cluster_name or names variable must be specified.") : null)

  validate_dns_prefix = ((var.dns_prefix == null) ?
  file("ERROR: dns_prefix or names variable must be specified.") : null)

  validate_critical_addons = ((length([for k, v in local.additional_node_pools : k if v.only_critical_addons_enabled == true]) > 0) ?
  file("ERROR: node pool attribute only_critical_addons_enabled can only be set to true for the default node pool") : null)

  validate_network_policy = ((var.network_policy == "azure" && var.network_plugin != "azure") ?
  file("ERROR: When network_policy is set to azure, the network_plugin field can only be set to azure.") : null) */
}
