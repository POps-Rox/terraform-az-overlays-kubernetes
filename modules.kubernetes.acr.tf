# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.
module "acr" {
  source  = "github.com/POps-Rox/tf-az-overlays-containerregistry"
  version = "~> 2.0"

  #depends_on = [ data.azurerm_virtual_network.aks_vnet ]
  # By default, this module will not create a resource group. If you wish 
  # to use an existing resource group, provide the name of the existing resource group.
  # using `existing_resource_group_name` will ignore `create_container_registry_resource_group` and `custom_resource_group_name`.
  # The location of the group  will remain the same if you use the current resource.
  existing_resource_group_name = local.resource_group_name
  location                     = local.location
  environment                  = "public"
  deploy_environment           = "dev"
  org_name                     = "anoa"
  workload_name                = "dev-acr"
  sku                          = "Premium"

  # Set a retention policy with care--deleted image data is UNRECOVERABLE.
  # A retention policy for untagged manifests is currently a preview feature of Premium container registries
  # The retention policy applies only to untagged manifests with timestamps after the policy is enabled. Default is `7` days.
  retention_policy = {
    days    = 10
    enabled = true
  }

  # Content trust is a feature of the Premium service tier of Azure Container Registry.
  enable_content_trust = true

  # Creating Private Endpoint requires, VNet name and address prefix to create a subnet
  # By default this will create a `privatelink.azurecr.io` DNS zone. 
  # To use existing private DNS zone specify `existing_private_dns_zone` with valid zone name
  enable_private_endpoint      = true
  virtual_network_name         = data.azurerm_virtual_network.aks_vnet.name
  existing_private_subnet_name = data.azurerm_subnet.aks_subnet.name
  # existing_private_dns_zone     = "demo.example.com"

  # Tags for Azure Resources
  add_tags = {
    example = "basic_container_registry_with_private_endpoint"
  }
}
