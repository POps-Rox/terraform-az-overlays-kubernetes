#output "echo_text" {
#  value = module.echo.echo_text
#}
output "subnet_id" {
  value = azurerm_subnet.aks_subnet.id
}

output "subnet_name" {
  value = azurerm_subnet.aks_subnet.name
}

output "vnet_subnet_id" {
  value = azurerm_subnet.aks_subnet.id

}

output "vnet_id" {
  value = azurerm_virtual_network.aks_vnet.id

}