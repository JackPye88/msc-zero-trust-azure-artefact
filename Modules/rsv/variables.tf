variable "root_id" {
  type        = string
  description = "The root identifier for resource naming conventions."
}

variable "environment" {
  type        = string
  description = "The environment name (e.g., dev, prod, staging)."
}

variable "location_short" {
  type        = string
  description = "Short code for the location (e.g., 'eus' for East US)."
}

variable "location" {
  type        = string
  description = "Full name of the location (e.g., 'East US')."
}

variable "rsv_rg_name" {
  type        = string
  description = "The resource group name suffix for the Recovery Services Vault."
}
variable "rg_long" {
  type        = string
  description = "The resource group name suffix for the Recovery Services Vault."
  default     = null
}
variable "subnet_name" {
  type        = string
  description = "The name of the subnet where the private endpoint will be created."
}
variable "subnet_id" {
  type        = string
  description = "The name of the subnet where the private endpoint will be created."
  default     = null
}

variable "virtual_network_name" {
  type        = string
  description = "The name of the virtual network where the subnet is located."
}
variable "primary_short" {
  type        = string
  description = "The name of the virtual network where the subnet is located."
}
variable "management_resources_tags" {
  type        = map(string)
  description = "A map of tags to assign to resources."
  default     = {}
}

variable "private_ip1" {
  type        = string
  description = "Prvate IP Number 1"
}

variable "private_ip2" {
  type        = string
  description = "Prvate IP Number 2"
}
variable "private_ip3" {
  type        = string
  description = "Prvate IP Number 3"
}

variable "private_ip4" {
  type        = string
  description = "Prvate IP Number 4"
}
variable "private_ip5" {
  type        = string
  description = "Prvate IP Number 5"
}
