
variable "create_resource_group" {
  description = "Create a new resource group for this example? Set to false to use an existing resource group."
  type        = bool
  default     = true
}

variable "custom_resource_group_name" {
  description = "A custom name for the resource group. If not specified, a name will be generated."
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to add to all resources in this example."
  type        = map(string)
  default = {
    "Environment" = "dev"
    "org"         = "anoa"
  }
}
