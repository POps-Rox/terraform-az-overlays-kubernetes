# v2.0.0 — azurerm 4.x upgrade (Phase 1 pilot)

## ⚠️ BREAKING CHANGES — `azurerm` provider 4.x

Consumers MUST be on Terraform `>= 1.10` and `azurerm ~> 4.20` before
upgrading. State migration for live AKS clusters is non-trivial — see the
upstream upgrade guide:
https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/4.0-upgrade-guide

### Provider / Terraform requirements

- Bump Terraform minimum required version from `>= 1.9` to `>= 1.10`.
- Bump `azurerm` provider version constraint from `~> 3.116` to `~> 4.20`.
- Add `azure/azapi ~> 2.0` to `required_providers` (used by sibling overlays
  for resources that were moved out of `azurerm` in 4.x; declared here so the
  selection is consistent across the fleet).
- `popsrox-utils` provider remains pinned to `POps-Rox/azutils ~> 1.0`. The
  local name in `required_providers` is intentionally kept as `popsrox`
  (matching the `popsrox_*` data-source/resource type prefix exposed by the
  current 1.x binary). Changing the local name to `popsrox-utils` would make
  Terraform infer an undeclared provider for `data "popsrox_resource_name"`.

### `azurerm_kubernetes_cluster` (`resources.kubernetes.tf`)

- `azure_active_directory_role_based_access_control.managed` argument removed
  — AAD integration is always managed in 4.x; the `azure_rbac_enabled`
  argument is the new entry point. The block now declares only
  `tenant_id` and `azure_rbac_enabled = true`.
- `default_node_pool.enable_auto_scaling` → `auto_scaling_enabled`.
- `default_node_pool.enable_host_encryption` → `host_encryption_enabled`.
- `default_node_pool.enable_node_public_ip` → `node_public_ip_enabled`.
- `default_node_pool.node_count` remains driven by the existing ternary
  (`auto_scaling_enabled ? null : node_count`) which already satisfies the
  4.x rule "`node_count` is required when `auto_scaling_enabled = false`".
- `network_profile.docker_bridge_cidr` was never set in this module's resource
  block (Docker is no longer used in AKS 1.24+); the field is removed from the
  `network_profile_options` input variable type and its validation block, see
  below.

### Variable schema (`variables.resources.kubernetes.tf`)

- **`node_pool_defaults` object type** — fields renamed to match the 4.x
  argument names so callers using `merge(var.node_pool_defaults, ...)` keep
  working without a translation shim:
  - `enable_auto_scaling` → `auto_scaling_enabled`
  - `enable_host_encryption` → `host_encryption_enabled`
  - `enable_node_public_ip` → `node_public_ip_enabled`
  Callers passing a custom `node_pool_defaults` or per-pool override map MUST
  rename these keys in their input.
- **`network_profile_options` object type** — `docker_bridge_cidr` removed
  from the object type, the validation `condition`, and the description.
  Callers passing a `network_profile_options` value MUST drop the
  `docker_bridge_cidr` key.
- Unused legacy variables (`default_node_pool_enable_auto_scaling`,
  `default_node_pool_enable_host_encryption`,
  `default_node_pool_enable_node_public_ip`, `docker_bridge_cidr`,
  `enable_kube_dashboard`) are left in place for backward compatibility of the
  public variable interface; they are not referenced by the module.

### Examples (`examples/scca_private_cluster_{commercial,gov}/`)

- `versions.tf` rewritten to match the new requirements.
- `azurerm_subnet.private_endpoint_network_policies_enabled = false` →
  `private_endpoint_network_policies = "Disabled"` (string enum in 4.x).
- `provider "azurerm" { skip_provider_registration = "true" ... }` removed
  — the argument was removed in 4.x. Equivalent behaviour is opt-in via
  `resource_provider_registrations = "none"`, which we do not set here
  (examples rely on the default `core` registration).

## Validation

- `terraform init -backend=false` + `terraform validate` succeeds on the root
  module and both example directories with `azurerm 4.72.0` (selected by the
  `~> 4.20` constraint).
- Full validation requires sibling overlays
  (`terraform-az-overlays-containerregistry`, `…-keyvault`,
  `…-resourcegroup`, `…-azregionslookup`) to also publish 4.x-compatible
  releases. During this pilot those submodules were stubbed locally for
  validation; consumers should pin to overlay versions that have all
  completed Phase 1.

# v1.0.0 - <date>

Added
- Add Something you added
