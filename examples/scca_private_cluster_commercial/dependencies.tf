
resource "azurerm_resource_group" "aks_rg" {
  name     = "tf-anoa-public-aks-rg"
  location = module.mod_azure_region_lookup.location_cli
}
resource "azurerm_virtual_network" "aks_vnet" {
  name                = "vnet-aks"
  location            = module.mod_azure_region_lookup.location_cli
  resource_group_name = azurerm_resource_group.aks_rg.name
  address_space       = ["10.1.0.0/16"]
}

#creates the subnet for the private cluster
resource "azurerm_subnet" "aks_subnet" {
  name                                      = "snet-aks"
  resource_group_name                       = azurerm_resource_group.aks_rg.name
  virtual_network_name                      = azurerm_virtual_network.aks_vnet.name
  address_prefixes                          = ["10.1.2.0/24"]
  private_endpoint_network_policies_enabled = false
}

#creates the ingress subnet for the private cluster load balancer
resource "azurerm_subnet" "aks_subnet_ingress" {
  name                                      = "snet-aks-ingress"
  resource_group_name                       = azurerm_resource_group.aks_rg.name
  virtual_network_name                      = azurerm_virtual_network.aks_vnet.name
  address_prefixes                          = ["10.1.3.0/24"]
  private_endpoint_network_policies_enabled = false
}

#creates the load balancer for the private cluster ingress
resource "azurerm_lb" "ingress_aks_lb" {
  name                = "ingress_aks_lb"
  location            = module.mod_azure_region_lookup.location_cli
  resource_group_name = azurerm_resource_group.aks_rg.name
  frontend_ip_configuration {
    name                          = "LoadBalancerFrontEnd"
    subnet_id                     = azurerm_subnet.aks_subnet_ingress.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.3.5"
  }
}

#creates route table for the private cluster egress to internet
resource "azurerm_route_table" "rt" {
  name                = "rt-aks_egress"
  location            = module.mod_azure_region_lookup.location_cli
  resource_group_name = azurerm_resource_group.aks_rg.name

  route {
    name                   = "1kubenetfw_fw_r"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = var.firewall_private_ip
  }
}

#associates the route table to the subnet
resource "azurerm_subnet_route_table_association" "snet_rt" {
  subnet_id      = azurerm_subnet.aks_subnet.id
  route_table_id = azurerm_route_table.rt.id
}

#wl spoke to hub peering
resource "azurerm_virtual_network_peering" "aks_spoke_to_hub" {
  name                         = "aks_spoke_to_hub"
  resource_group_name          = azurerm_resource_group.aks_rg.name
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  virtual_network_name         = azurerm_virtual_network.aks_vnet.name
  remote_virtual_network_id    = "/subscriptions/ENTER_SUB_ID_HERE/resourceGroups/anoa-eus-hub-core-dev-rg/providers/Microsoft.Network/virtualNetworks/anoa-eus-hub-core-dev-vnet"
}

#hub to wl spoke peering
resource "azurerm_virtual_network_peering" "hub_to_aks_spoke" {
  name                         = "hub_to_aks_spoke"
  allow_forwarded_traffic      = true
  allow_virtual_network_access = true
  #allow_remote_virtual_network_access = true
  resource_group_name       = "anoa-eus-hub-core-dev-rg"
  virtual_network_name      = "anoa-eus-hub-core-dev-vnet"
  remote_virtual_network_id = azurerm_virtual_network.aks_vnet.id
}


resource "azurerm_log_analytics_workspace" "aks" {
  name                = "aks-la-01"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_log_analytics_solution" "solution" {
  solution_name         = "ContainerInsights"
  location              = azurerm_log_analytics_workspace.aks.location
  resource_group_name   = azurerm_log_analytics_workspace.aks.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.aks.id
  workspace_name        = azurerm_log_analytics_workspace.aks.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}
