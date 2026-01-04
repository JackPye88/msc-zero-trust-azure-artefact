# Input variable definitions

variable "vnet_name" {
  description = "Name of the Virtual Network must be Unique."
  type        = string
}



variable "location" {
  description = "Name of the Location."
  type        = string
}

variable "rg_name" {
  description = "Name of the Resource Group."
  type        = string
}

variable "vnet_address" {
  description = "Name of the Resource Group."
  type        = string
}

variable "enforce_private_link_endpoint_network_policies" {
  description = "Name of the Resource Group."
  type        = string
  default     = "true"
}
variable "hub_name" {
  description = "Name of the Resource Group."
  type        = string
}
variable "root_id" {
  description = "Name of the Resource Group."
  type        = string
}
variable "region_short" {
  description = "Name of the Resource Group."
  type        = string
}

variable "tags" {
  description = "tags to apply."
  type        = map(string)
  default     = {}
}
variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  type        = string

}
variable "hub_resource_group" {
  description = "Resource Group for Hub VNET"
  type        = string

}

variable "vnetgateway_routes_enabled" {
  description = "Routes for VPN Gateway"
  type        = bool
  default     = true
}
variable "next_hop_address" {
  description = "Next Hop Address for Route Tables"
  type        = string

}
variable "dns_servers" {
  description = "List of DNS server IP addresses to assign to the virtual network."
  type        = list(string)
  default     = [] # Default to an empty list if no value is provided
}

variable "network_watcher_flow_log" {
  type    = bool
  default = false
}
variable "nsg_flow_storage_account" {
  type    = string
  default = null
}

variable "log_analytics_workspace_id_workspaceid" {
  type    = string
  default = null


}
