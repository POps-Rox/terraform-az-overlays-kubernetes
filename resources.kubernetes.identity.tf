# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

resource "azurerm_user_assigned_identity" "aks" {
  count = (var.identity_type == "UserAssigned" && var.user_assigned_identity == null ? 1 : 0)

  resource_group_name = local.resource_group_name
  location            = local.location
  name                = local.user_assigned_identity_name

  tags = var.add_tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_role_assignment" "subnet_network_contributor" {
  for_each = (var.virtual_network == null ? {} : (var.configure_network_role ? var.virtual_network.subnets : {}))

  scope                = each.value.id
  role_definition_name = "Network Contributor"
  principal_id         = local.aks_identity_id
}


resource "azurerm_role_assignment" "route_table_network_contributor" {
  count = (var.virtual_network == null ? 0 : 1)

  scope                = var.virtual_network.route_table_id
  role_definition_name = "Network Contributor"
  principal_id = (var.user_assigned_identity == null ? azurerm_user_assigned_identity.aks[0].principal_id :
  var.user_assigned_identity.principal_id)
}

#assign contributor permsission to the subnet for the private cluster
resource "azurerm_role_assignment" "aks_identity_contributor" {
  principal_id         = azurerm_user_assigned_identity.aks[0].principal_id #azurerm_user_assigned_identity.aks_identity.principal_id
  role_definition_name = "Contributor"                                      # You can use a more specific role if needed
  scope                = data.azurerm_route_table.rt.id
}

## AKS Admin/Infra Team Role 
## List cluster admin credential action.
resource "azurerm_role_assignment" "admin_user" {
  scope                = azurerm_kubernetes_cluster.aks_cluster.id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  principal_id         = azuread_group.aksadminteam.id
}


## AKS Dev Team Role 
## List cluster user credential action.
resource "azurerm_role_assignment" "appdevs_user" {
  scope                = azurerm_kubernetes_cluster.aks_cluster.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = azuread_group.aksdevteam.id
}


## AKS Contributor/Operations Team Role 
## Grants access to read and write Azure Kubernetes Service clusters
resource "azurerm_role_assignment" "ops_user" {
  scope                = azurerm_kubernetes_cluster.aks_cluster.id
  role_definition_name = "Azure Kubernetes Service Contributor Role"
  principal_id         = azuread_group.aksopsteam.id
}



# Azure Kubernetes Service RBAC Reader Role 
## Allows read-only access to see most objects in a namespace. 
## It does not allow viewing roles or role bindings. This role does not allow viewing Secret
resource "azurerm_role_assignment" "reader_user" {
  scope                = azurerm_kubernetes_cluster.aks_cluster.id
  role_definition_name = "Azure Kubernetes Service RBAC Reader"
  principal_id         = azuread_group.aksreader.id
}

# Azure Kubernetes Service RBAC Writer Role 
## Allows read/write access to most objects in a namespace. 
## This role does not allow viewing or modifying roles or role bindings. However, this role allow

resource "azurerm_role_assignment" "writer_user" {
  scope                = azurerm_kubernetes_cluster.aks_cluster.id
  role_definition_name = "Azure Kubernetes Service RBAC Writer"
  principal_id         = azuread_group.akswriter.id
}

