variable "subnet_address" {
  type = string
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to the resource."
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  type        = string

}
variable "vnet_descriptor" {
  type    = string
  default = "spoke"
}

variable "root_id" {
  type = string
}

variable "next_hop_address" {
  type        = string
  description = "The name of the route table."
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

variable "environment" {
  type = string

}
variable "subnet_descriptor" {
  type = string

}
variable "location_short" {
  type = string

}
variable "location_long" {
  type = string

}
variable "instance" {
  type    = string
  default = "001"
}

variable "service_delegation" {
  description = "List of service delegations for the subnet."
  type = list(object({
    name    = string
    actions = list(string)
  }))
  default = []
}

variable "service_endpoints" {
  description = "List of service endpoints to associate with the subnet."
  type        = list(string)
  default     = []
}

variable "deny_all_outbound" {
  description = "Determines if the DenyAllOutbound rule should be created"
  type        = bool
  default     = true
}
variable "default_route_deploy" {
  description = "Determines if the default_route_deploy  should be created"
  type        = bool
  default     = true
}

variable "vnet_id" {
  description = "vnet_id_for_dependencies"
  type        = string
  default     = null
}