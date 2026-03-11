#aks subnet_ID 
output "azurerm_virtual_network" {
  description = "azurerm_virtual_network"
  value       = azurerm_virtual_network.aks_vnet

}

output "aks_subnet" {
  description = "aks subnet"
  value       = azurerm_subnet.aks_subnet
}

output "aks_subnet_id" {
  description = "aks subnet ID"
  value       = azurerm_subnet.aks_subnet.id

}

