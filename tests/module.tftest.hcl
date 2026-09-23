# Functional tests for the Kubernetes overlay.
#
# These tests use mock_provider, so they run without Azure credentials and are
# safe on fork PRs. They exercise module decisions that terraform validate
# cannot prove: naming precedence, conditional resources, tag merging, location
# passthrough, node-pool autoscaling branches, AKS 5.x SKU mapping, and managed
# identity branching.

mock_provider "azapi" {}

mock_provider "azuread" {
  mock_resource "azuread_group" {
    defaults = {
      id = "00000000-0000-0000-0000-000000000100"
    }
  }
}

mock_provider "popsrox" {
  mock_data "popsrox_resource_name" {
    defaults = {
      result = "anoaeusworkloaddevaks"
    }
  }
}

mock_provider "azurerm" {
  mock_data "azurerm_subscription" {
    defaults = {
      subscription_id = "00000000-0000-0000-0000-000000000000"
      tenant_id       = "00000000-0000-0000-0000-000000000001"
      display_name    = "mock subscription"
    }
  }

  mock_data "azurerm_resource_group" {
    defaults = {
      id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-existing"
      name     = "rg-existing"
      location = "eastus"
    }
  }

  mock_data "azurerm_subnet" {
    defaults = {
      id                   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-existing/providers/Microsoft.Network/virtualNetworks/vnet-aks/subnets/snet-aks"
      name                 = "snet-aks"
      virtual_network_name = "vnet-aks"
      resource_group_name  = "rg-existing"
    }
  }

  mock_data "azurerm_virtual_network" {
    defaults = {
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-existing/providers/Microsoft.Network/virtualNetworks/vnet-aks"
      name                = "vnet-aks"
      resource_group_name = "rg-existing"
      location            = "eastus"
    }
  }

  mock_data "azurerm_route_table" {
    defaults = {
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-existing/providers/Microsoft.Network/routeTables/rt-aks_egress"
      name                = "rt-aks_egress"
      resource_group_name = "rg-existing"
    }
  }

  mock_resource "azurerm_user_assigned_identity" {
    defaults = {
      id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-existing/providers/Microsoft.ManagedIdentity/userAssignedIdentities/mock-aks-identity"
      principal_id = "00000000-0000-0000-0000-000000000200"
      client_id    = "00000000-0000-0000-0000-000000000201"
    }
  }

  mock_resource "azurerm_kubernetes_cluster" {
    defaults = {
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-existing/providers/Microsoft.ContainerService/managedClusters/mock-aks"
      node_resource_group = "MC-mock-aks"
      kubelet_identity = [{
        object_id = "00000000-0000-0000-0000-000000000300"
      }]
      identity = [{
        principal_id = "00000000-0000-0000-0000-000000000301"
        tenant_id    = "00000000-0000-0000-0000-000000000001"
      }]
      network_profile = [{
        load_balancer_profile = [{
          effective_outbound_ips = []
        }]
      }]
      kube_config = [{
        host                   = "https://mock.example.invalid"
        username               = "mock-user"
        password               = "mock-password"
        client_certificate     = "mock-cert"
        client_key             = "mock-key"
        cluster_ca_certificate = "mock-ca"
      }]
      kube_admin_config     = []
      kube_config_raw       = "mock-kubeconfig"
      kube_admin_config_raw = ""
    }
  }
}

variables {
  location                     = "eastus"
  environment                  = "public"
  deploy_environment           = "dev"
  workload_name                = "workload"
  org_name                     = "anoa"
  create_aks_resource_group    = false
  existing_resource_group_name = "rg-existing"
  dns_prefix                   = "aksdns"
  log_analytics_workspace_id   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-existing/providers/Microsoft.OperationalInsights/workspaces/law-aks"
  create_aks_keyvault          = false
  enable_private_endpoint      = false
  network_profile_options = {
    dns_service_ip = "10.0.0.10"
    service_cidr   = "10.0.0.0/16"
  }
  node_pool_defaults = {
    vm_size                      = "Standard_DS2_v2"
    node_count                   = 2
    auto_scaling_enabled         = false
    min_count                    = null
    max_count                    = null
    host_encryption_enabled      = false
    node_public_ip_enabled       = false
    max_pods                     = 30
    node_labels                  = { role = "system" }
    only_critical_addons_enabled = false
    orchestrator_version         = null
    os_disk_size_gb              = 64
    os_disk_type                 = "Managed"
    type                         = "VirtualMachineScaleSets"
    tags                         = { pool = "default" }
    subnet                       = null
    mode                         = "User"
    node_taints                  = null
    max_surge                    = "1"
    eviction_policy              = null
    os_type                      = "Linux"
    priority                     = "Regular"
    proximity_placement_group_id = null
    spot_max_price               = null
  }
}

run "generated_name_is_used_when_custom_name_is_empty" {
  command = plan

  variables {
    custom_cluster_name = ""
  }

  assert {
    condition     = azurerm_kubernetes_cluster.aks_cluster.name == "anoaeusworkloaddevaks"
    error_message = "An empty custom_cluster_name must fall through to the generated name, got: ${azurerm_kubernetes_cluster.aks_cluster.name}"
  }
}

run "custom_name_overrides_generated_name" {
  command = plan

  variables {
    custom_cluster_name = "explicit-aks-name"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.aks_cluster.name == "explicit-aks-name"
    error_message = "custom_cluster_name must take precedence over the generated name, got: ${azurerm_kubernetes_cluster.aks_cluster.name}"
  }
}

run "locks_are_not_created_by_default" {
  command = plan

  assert {
    condition     = length(azurerm_management_lock.kubernetes_level_lock) == 0
    error_message = "enable_resource_locks defaults to false, so no AKS management lock should be planned"
  }
}

run "enabling_locks_creates_named_cluster_lock" {
  command = plan

  variables {
    enable_resource_locks = true
  }

  assert {
    condition     = length(azurerm_management_lock.kubernetes_level_lock) == 1
    error_message = "enable_resource_locks = true must create exactly one AKS management lock"
  }

  assert {
    condition     = azurerm_management_lock.kubernetes_level_lock[0].name == "anoaeusworkloaddevaks-CanNotDelete-lock"
    error_message = "Lock name must be derived from the effective AKS cluster name and lock level, got: ${azurerm_management_lock.kubernetes_level_lock[0].name}"
  }
}

run "tags_and_location_are_passed_to_cluster" {
  command = plan

  variables {
    add_tags = {
      costCenter = "cc-1234"
    }
  }

  assert {
    condition     = azurerm_kubernetes_cluster.aks_cluster.location == "eastus"
    error_message = "location input must be applied to the AKS cluster"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.aks_cluster.tags["costCenter"] == "cc-1234"
    error_message = "Caller add_tags must be merged onto the AKS cluster"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.aks_cluster.tags["env"] == "dev"
    error_message = "Default tags must be merged onto the AKS cluster"
  }
}

run "manual_default_node_pool_sets_node_count" {
  command = plan

  assert {
    condition     = azurerm_kubernetes_cluster.aks_cluster.default_node_pool[0].auto_scaling_enabled == false
    error_message = "Default node pool should have autoscaling disabled by default"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.aks_cluster.default_node_pool[0].node_count == 2
    error_message = "When autoscaling is disabled, node_count must be passed through"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.aks_cluster.default_node_pool[0].min_count == null && azurerm_kubernetes_cluster.aks_cluster.default_node_pool[0].max_count == null
    error_message = "When autoscaling is disabled, min_count and max_count must be null"
  }
}

run "autoscaled_default_node_pool_uses_min_max" {
  command = plan

  variables {
    node_pools = {
      default = {
        auto_scaling_enabled = true
        node_count           = 5
        min_count            = 1
        max_count            = 4
      }
    }
  }

  assert {
    condition     = azurerm_kubernetes_cluster.aks_cluster.default_node_pool[0].auto_scaling_enabled == true
    error_message = "Node pool override should enable autoscaling"
  }


  assert {
    condition     = azurerm_kubernetes_cluster.aks_cluster.default_node_pool[0].min_count == 1 && azurerm_kubernetes_cluster.aks_cluster.default_node_pool[0].max_count == 4
    error_message = "When autoscaling is enabled, min_count and max_count must be passed through"
  }
}

run "default_user_assigned_identity_is_created_and_used" {
  command = plan

  assert {
    condition     = length(azurerm_user_assigned_identity.aks) == 1
    error_message = "Default UserAssigned identity mode should create exactly one managed identity"
  }

  assert {
    condition     = azurerm_user_assigned_identity.aks[0].name == "aks-anoaeusworkloaddevaks-control-plane"
    error_message = "Module-created managed identity name should derive from the effective cluster name"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.aks_cluster.identity[0].type == "UserAssigned"
    error_message = "AKS should use UserAssigned identity by default"
  }
}

run "supplied_user_assigned_identity_skips_identity_resource" {
  command = plan

  variables {
    user_assigned_identity = {
      id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-existing/providers/Microsoft.ManagedIdentity/userAssignedIdentities/existing-aks-identity"
      principal_id = "00000000-0000-0000-0000-000000000400"
      client_id    = "00000000-0000-0000-0000-000000000401"
    }
  }

  assert {
    condition     = length(azurerm_user_assigned_identity.aks) == 0
    error_message = "Supplying user_assigned_identity should skip creating a new managed identity"
  }

  assert {
    condition     = tolist(azurerm_kubernetes_cluster.aks_cluster.identity[0].identity_ids)[0] == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-existing/providers/Microsoft.ManagedIdentity/userAssignedIdentities/existing-aks-identity"
    error_message = "AKS should use the supplied managed identity id"
  }

  assert {
    condition     = azurerm_role_assignment.aks_identity_contributor.principal_id == "00000000-0000-0000-0000-000000000400"
    error_message = "Role assignment should use the supplied managed identity principal_id"
  }
}

run "legacy_paid_sku_maps_to_standard_for_azurerm_5" {
  command = plan

  variables {
    sku_tier = "Paid"
  }

  assert {
    condition     = azurerm_kubernetes_cluster.aks_cluster.sku_tier == "Standard"
    error_message = "azurerm 5.x no longer accepts Paid; the module must map legacy Paid to Standard"
  }
}
