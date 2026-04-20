locals {
  # Naming locals/constants
  name_prefix = lower(var.name_prefix)
  name_suffix = lower(var.name_suffix)

  resource_group_name = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, module.mod_scaffold_rg.*.resource_group_name, [""]), 0)
  location            = element(coalescelist(data.azurerm_resource_group.rgrp.*.location, module.mod_scaffold_rg.*.resource_group_location, [""]), 0)

  cluster_name      = coalesce(var.custom_cluster_name, data.popsrox_resource_name.aks.result)
  aks_identity_name = coalesce(var.aks_user_assigned_identity_custom_name, data.popsrox_resource_name.aks_identity.result)
}
