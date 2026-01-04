variable "automation_account_name" {
  type        = string
  description = "The name of the Automation Account."
}

variable "resource_group_name" {
  type        = string
  description = "The resource group where the Automation Account will be created."
}

variable "location" {
  type        = string
  description = "The location where the Automation Account will be created."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags to apply to the Automation Account."
}

variable "subnet_id" {
  type        = string
  description = "The name of the subnet where the resource (e.g., private endpoint) will be created."
}

variable "virtual_network_name" {
  type        = string
  description = "The name of the virtual network where the subnet is located."
}

variable "vnetrg" {
  type        = string
  description = "The name of the resource group that contains the virtual network."
}

variable "root_id" {
  type        = string
  description = "The name of the resource group that contains the virtual network."
}
variable "private_ip1" {
  type        = string
  description = "Prvate IP Number 1"
}

variable "private_ip2" {
  type        = string
  description = "Prvate IP Number 2"
}