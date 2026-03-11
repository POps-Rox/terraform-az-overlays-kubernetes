# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#------------------------------------------------------------
# Kubernetes Lock configuration - Remove if not needed 
#------------------------------------------------------------
resource "azurerm_management_lock" "kubernetes_level_lock" {
  count = var.enable_resource_locks ? 1 : 0

  name       = "${var.cluster_name}-${var.lock_level}-lock"
  scope      = azurerm_kubernetes_cluster.aks_cluster.id
  lock_level = var.lock_level
  notes      = "Azure Kubernetes Cluster '${var.cluster_name}' is locked with '${var.lock_level}' level."
}
