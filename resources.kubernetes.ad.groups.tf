
## AKS Admin/Infra Team Group
## List cluster admin credential action.
resource "azuread_group" "aksadminteam" {

  display_name     = var.aks_admin_group
  security_enabled = true
}


output "admin_object_id" {
  value = azuread_group.aksadminteam.object_id
}


## AKS Dev Team Group  
## List cluster user credential action.
resource "azuread_group" "aksdevteam" {
  display_name     = var.aks_user_group
  security_enabled = true
}


output "appdev_object_id" {
  value = azuread_group.aksdevteam.object_id
}

## AKS Contributor/Operations Team Group
## Grants access to read and write Azure Kubernetes Service clusters
resource "azuread_group" "aksopsteam" {
  display_name     = var.aks_ops_group
  security_enabled = true
}

output "operations_object_id" {
  value = azuread_group.aksopsteam.object_id
}

# Azure Kubernetes Service RBAC Reader Group 
## Allows read-only access to see most objects in a namespace. 
## It does not allow viewing roles or role bindings. This role does not allow viewing Secret

resource "azuread_group" "aksreader" {
  display_name     = var.aks_reader_group
  security_enabled = true
}

output "reader_object_id" {
  value = azuread_group.aksreader.object_id
}

# Azure Kubernetes Service RBAC Writer Group 
## Allows read/write access to most objects in a namespace. 
## This role does not allow viewing or modifying roles or role bindings. However, this role allow

resource "azuread_group" "akswriter" {
  display_name     = var.aks_writer_group
  security_enabled = true
}

output "writer_object_id" {
  value = azuread_group.akswriter.object_id
}



 