# variables for AKS
variable "aks_name" {
  type    = string
  default = "aks"
}

variable "aks_location" {
  type    = string
  default = "eastus"
}

variable "aks_resource_group_name" {
  type    = string
  default = "aks"
}

variable "kubernetes_version" {
  description = "Kubernetes version to deploy. Will deploy newest AKS version if this value is not set."
  type        = string
  default     = null
}

variable "private_dns_zone_type" {
  type        = string
  default     = "System"
  description = <<EOD
Set AKS private dns zone if needed and if private cluster is enabled (privatelink.<region>.azmk8s.io)
- "Custom" : You will have to deploy a private Dns Zone on your own and pass the id with <private_dns_zone_id> variable
If this settings is used, aks user assigned identity will be "userassigned" instead of "systemassigned"
and the aks user must have "Private DNS Zone Contributor" role on the private DNS Zone
- "System" : AKS will manage the private zone and create it in the same resource group as the Node Resource Group
- "None" : In case of None you will need to bring your own DNS server and set up resolving, otherwise cluster will have issues after provisioning.

https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#`
EOD
}

variable "private_dns_zone_id" {
  type        = string
  default     = null
  description = "Id of the private DNS Zone when <private_dns_zone_type> is custom"
}

variable "aks_pod_cidr" {
  type    = string
  default = ""
}

variable "docker_bridge_cidr" {
  type    = string
  default = ""
}

variable "service_cidr" {
  type    = string
  default = ""
}

variable "load_balancer_sku" {
  type    = string
  default = "Basic"
}

variable "dns_prefix" {
  description = "DNS prefix specified when creating the managed cluster."
  type        = string
  default     = "aks.dns.prefix"
}

variable "workload_identity_enabled" {
  type    = bool
  default = true
}
variable "oidc_issuer_enabled" {
  type    = bool
  default = true
}
variable "open_service_mesh_enabled" {
  type    = bool
  default = false
}
variable "image_cleaner_enabled" {
  type    = bool
  default = false
}
variable "azure_policy_enabled" {
  type    = bool
  default = false
}
variable "http_application_routing_enabled" {
  description = "At this time HTTP Application Routing is not supported in Azure China or Azure US Government."
  type        = bool
  default     = false
}

variable "default_node_pool" {
  type = object({
    name = string
  })
  default = {
    name = "var.default_node_pool_name"
  }
}

variable "nodes_pools" {
  type    = list(string)
  default = []
}

variable "default_node_pool_name" {
  description = "Default node pool name.  Value refers to key within node_pools variable."
  type        = string
  default     = "default"
}

variable "default_node_pool_type" {
  type    = string
  default = "VirtualMachineScaleSets"
}

variable "default_node_pool_vm_size" {
  type    = string
  default = "Standard_D2s_v3"
}

#var for aks vnet
variable "vnet_subnet_id" {
  type    = string
  default = ""
}

variable "pod_subnet_id" {
  type    = string
  default = ""
}

variable "nodes_subnet_id" {
  type    = string
  default = null
}

variable "default_node_pool_availability_zones" {
  type    = list(string)
  default = ["1", "2", "3"]
}

variable "default_node_pool_node_labels" {
  type = map(string)
  default = {
    "nodepool" = "default"
  }
}

variable "default_node_pool_node_taints" {
  type    = list(string)
  default = ["nodepool=default:NoSchedule"]
}

variable "default_node_pool_enable_auto_scaling" {
  type    = bool
  default = false
}

variable "default_node_pool_enable_host_encryption" {
  type    = bool
  default = true
}

variable "default_node_pool_eviction_policy" {
  type    = string
  default = "Delete"
}

variable "default_node_pool_enable_node_public_ip" {
  type    = bool
  default = false
}

variable "default_node_pool_max_pods" {
  type    = number
  default = 110
}

variable "default_node_pool_max_count" {
  type    = number
  default = null
}

variable "default_node_pool_min_count" {
  type    = number
  default = null
}

variable "default_node_pool_node_count" {
  type    = number
  default = 3
}

variable "default_node_pool_os_disk_type" {
  type    = string
  default = "Managed"
}



variable "default_node_pool_os_disk_size_gb" {
  type    = number
  default = 30
}

variable "default_node_pool_os_type" {
  type    = string
  default = "managed"
}

variable "default_node_pool_zones" {
  type    = list(string)
  default = ["1", "2", "3"]
}

variable "default_node_pool_orchestrator_version" {
  type    = string
  default = "1.24.3"
}

variable "default_node_pool_priority" {
  type    = string
  default = "Regular"
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

########################
# AKS Configuration   ##
########################

variable "cluster_name" {
  description = "Name of AKS cluster."
  type        = string
  default     = null
}

variable "node_resource_group" {
  description = "The name of the Resource Group where the Kubernetes Nodes should exist."
  type        = string
  default     = null
}

variable "identity_type" {
  description = "SystemAssigned or UserAssigned."
  type        = string
  default     = "UserAssigned"

  validation {
    condition = (
      var.identity_type == "UserAssigned" ||
      var.identity_type == "SystemAssigned"
    )
    error_message = "Identity must be one of 'SystemAssigned' or 'UserAssigned'."
  }
}

variable "user_assigned_identity" {
  description = "User assigned identity for the manged cluster (leave and the module will create one)."
  type = object({
    id           = string
    principal_id = string
    client_id    = string
  })
  default = null
}

variable "user_assigned_identity_name" {
  description = "Name of user assigned identity to be created (if applicable)."
  type        = string
  default     = null
}

variable "sku_tier" {
  description = "Sets the cluster's SKU tier. The paid tier has a financially-backed uptime SLA. Read doc [here](https://docs.microsoft.com/en-us/azure/aks/uptime-sla)."
  type        = string
  default     = "Free"

  validation {
    condition     = contains(["free", "paid"], lower(var.sku_tier))
    error_message = "Available SKU Tiers are \"Free\" and \"Paid\"."
  }
}

variable "network_plugin" {
  description = "network plugin to use for networking (azure or kubenet)"
  type        = string
  default     = "kubenet"

  validation {
    condition = (
      var.network_plugin == "kubenet" ||
      var.network_plugin == "azure"
    )
    error_message = "Network Plugin must set to kubenet or azure."

  }
}

variable "outbound_type" {
  description = "outbound (egress) routing method which should be used for this Kubernetes Cluster"
  type        = string
  default     = "userDefinedRouting"
}

variable "pod_cidr" {
  description = "used for pod IP addresses"
  type        = string
  default     = null
}

variable "network_profile_options" {
  description = "docker_bridge_cidr, dns_service_ip and service_cidr should all be empty or all should be set"
  type = object({
    docker_bridge_cidr = string
    dns_service_ip     = string
    service_cidr       = string
  })
  default = null

  validation {
    condition = (
      ((var.network_profile_options == null) ? true :
        ((var.network_profile_options.docker_bridge_cidr != null) &&
          (var.network_profile_options.dns_service_ip != null) &&
      (var.network_profile_options.service_cidr != null)))
    )
    error_message = "Incorrect values set. docker_bridge_cidr, dns_service_ip and service_cidr should all be empty or all should be set."

  }
}

variable "network_policy" {
  description = "Sets up network policy to be used with Azure CNI."
  type        = string
  default     = null

  validation {
    condition = (
      (var.network_policy == null) ||
      (var.network_policy == "azure") ||
      (var.network_policy == "calico")
    )
    error_message = "Network pollicy must be azure or calico."
  }
}

variable "node_pools" {
  description = "node pools"
  type        = any # top level keys are node pool names, sub-keys are subset of node_pool_defaults keys
  default     = { default = {} }
}

variable "node_pool_defaults" {
  description = "node pool defaults"
  type = object({
    vm_size                      = string
    node_count                   = number
    enable_auto_scaling          = bool
    min_count                    = number
    max_count                    = number
    enable_host_encryption       = bool
    enable_node_public_ip        = bool
    max_pods                     = number
    node_labels                  = map(string)
    only_critical_addons_enabled = bool
    orchestrator_version         = string
    os_disk_size_gb              = number
    os_disk_type                 = string
    type                         = string
    tags                         = map(string)
    subnet                       = string # must be key from node_pool_subnets variable

    # settings below not available in default node pools
    mode                         = string
    node_taints                  = list(string)
    max_surge                    = string
    eviction_policy              = string
    os_type                      = string
    priority                     = string
    proximity_placement_group_id = string
    spot_max_price               = number
  })
  default = { name = null
    vm_size                      = "Standard_DS2_v2" # "Standard_B2s"
    node_count                   = 1
    enable_auto_scaling          = false
    min_count                    = null
    max_count                    = null
    enable_host_encryption       = false
    enable_node_public_ip        = false
    max_pods                     = null
    node_labels                  = null
    only_critical_addons_enabled = false
    orchestrator_version         = null
    os_disk_size_gb              = null
    os_disk_type                 = "Managed"
    type                         = "VirtualMachineScaleSets"
    tags                         = null
    subnet                       = null # must be a key from node_pool_subnets variable

    # settings below not available in default node pools
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


variable "virtual_network" {
  description = "Virtual network info."
  type = object({
    subnets = map(object({
      id = string
    }))
    route_table_id = string
  })
  default = null
}

variable "configure_network_role" {
  description = "Add Network Contributor role for identity on input subnets."
  type        = bool
  default     = true
}

variable "windows_profile" {
  description = "windows profile admin user/pass"
  type = object({
    admin_username = string
    admin_password = string
  })
  default = null

  validation {
    condition = (
      var.windows_profile == null ? true :
      ((var.windows_profile.admin_username != null) &&
        (var.windows_profile.admin_username != "") &&
        (var.windows_profile.admin_password != null) &&
      (var.windows_profile.admin_password != ""))
    )
    error_message = "Windows profile requires both admin_username and admin_password."
  }
}

variable "rbac" {
  description = "role based access control settings"
  type = object({
    enabled        = bool
    ad_integration = bool
  })
  default = {
    enabled        = true
    ad_integration = false
  }

  validation {
    condition = (
      (var.rbac.enabled && var.rbac.ad_integration) ||
      (var.rbac.enabled && var.rbac.ad_integration == false) ||
      (var.rbac.enabled == false && var.rbac.ad_integration == false)
    )
    error_message = "Role based access control must be enabled to use Active Directory integration."
  }
}

variable "rbac_admin_object_ids" {
  description = "Admin group object ids for use with rbac active directory integration"
  type        = map(string) # keys are only for documentation purposes
  default     = {}
}

variable "enable_kube_dashboard" {
  description = "enable kubernetes dashboard"
  type        = bool
  default     = false
}

variable "enable_azure_policy" {
  description = "to apply at-scale enforcements and safeguards on your clusters in a centralized, consistent manner"
  type        = bool
  default     = false
}

variable "api_server_authorized_ip_ranges" {
  description = "authorized IP ranges to communicate with K8s API"
  type        = map(string)
  default     = null
}

variable "acr_pull_access" {
  description = "List of Azure Container Registries ids where AKS needs pull access."
  type        = list(string)
  default     = []
}

variable "log_analytics_workspace_id" {
  description = "ID of the Azure Log Analytics Workspace"
  type        = string
  default     = null
}

variable "key_vault_secrets_provider" {
  description = "key vault secrets provider secret rotation enabled / secret rotation interval"
  type = object({
    secret_rotation_enabled  = string
    secret_rotation_interval = string
  })
  default = null

  validation {
    condition = (
      var.key_vault_secrets_provider == null ? true :
      ((var.key_vault_secrets_provider.secret_rotation_enabled != null) &&
        (var.key_vault_secrets_provider.secret_rotation_enabled != "") &&
        (var.key_vault_secrets_provider.secret_rotation_interval != null) &&
      (var.key_vault_secrets_provider.secret_rotation_interval != ""))
    )
    error_message = " key vault secrets provider requires both secret rotation enabled and secret rotation interval"
  }
}





