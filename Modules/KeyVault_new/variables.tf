variable "kv_name" {
  type        = string
  description = "The name of the Key Vault."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group."
}

variable "subnet_name" {
  type        = string
  description = "The name of the subnet for the private endpoint."
}

variable "subnet_id" {
  type        = string
  description = "The name of the subnet for the private endpoint."
  default     = null
}

variable "ip_rules" {
  description = "List of IP addresses to allow access to the Key Vault"
  type        = list(string)
  default     = []
}
variable "environment" {
  type        = string
  description = "The environment name."
}

variable "virtual_network_name" {
  type        = string
  description = "The name of the virtual network for the private endpoint."
}

variable "location" {
  type        = string
  description = "The location/region where the resource is created."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags to assign to the resource."
}

variable "user_object_id" {
  type        = string
  description = "The object ID of the user."
}

variable "root_id" {
  type        = string
  description = "The root identifier."
}

variable "primary_region" {
  type        = string
  description = "The primary region."
}

variable "shortlocation" {
  type        = string
  description = "The short name for the location."
}
variable "private_ip_address" {
  type        = string
  description = "The private_ip_address."
}
variable "kv_depends_on" {
  type        = any
  default     = null
  description = "Helps with dependencies."
}


variable "connect_from_subnet_id" {
  description = "The IDs of the subnets to allow access from"
  type        = list(string)
  default     = []

}