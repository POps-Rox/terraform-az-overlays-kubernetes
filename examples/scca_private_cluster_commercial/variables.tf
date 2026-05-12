
variable "location" {
  type    = string
  default = "eastus"
}

# variable string we use Automating naming convention. Orgname=BC-, 
variable "org_name" {
  type    = string
  default = "tf-noops"
}

# AKS workload name using naming convention.. BC-AKS-USGV-dev. 
variable "workload_name" {
  type    = string
  default = ""

}

# deploy_environment used which Azure Cloud - Test/UAT/Dev/Prod etc.. 
variable "deploy_environment" {
  type    = string
  default = "ComDev"
}

# Env used which Azure Cloud - Gov/Public etc.. 
variable "environment" {
  type    = string
  default = "dev"
}

#az fw private ip for the private cluster egress to internet
variable "firewall_private_ip" {
  type    = string
  default = "10.8.4.68"
}

