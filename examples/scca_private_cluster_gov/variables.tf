
variable "location" {
  type    = string
  default = "usgovarizona"
}

variable "existing_resource_group_name" {
  type    = string
  default = null
}

# variable string we use Automating naming convention. Orgname=BC-, 
variable "org_name" {
  type    = string
  default = "tf-anoa"
}

# AKS workload name using naming convention..
variable "workload_name" {
  type    = string
  default = "gov"

}

# deploy_environment used which Azure Cloud - Test/UAT/Dev/Prod etc.. 
variable "deploy_environment" {
  type    = string
  default = "bc"
}

# Env used which Azure Cloud - Gov/Public etc.. 
variable "environment" {
  type    = string
  default = "gov"
}

# Network policy AKS
variable "network_plugin" {
  type    = string
  default = "azure"
}


variable "network_policy" {
  type    = string
  default = "calico"
}

variable "firewall_private_ip" {
  type    = string
  default = "10.8.4.68"

}