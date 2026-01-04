variable "root_id" {
  description = "The root ID"
  type        = string
}

variable "root_name" {
  description = "The root name"
  type        = string
}

variable "primary_short" {
  description = "Short name for the primary region"
  type        = string
}

variable "primary_long" {
  description = "Long name for the primary region"
  type        = string
}

variable "primary_long_no_space" {
  description = "Long name for the primary region without spaces"
  type        = string
}

variable "primary_long_no_space_lower" {
  description = "Long name for the primary region without spaces in lowercase"
  type        = string
}

variable "secondary_short" {
  description = "Short name for the secondary region"
  type        = string
}

variable "secondary_long" {
  description = "Long name for the secondary region"
  type        = string
}

variable "secondary_long_no_space" {
  description = "Long name for the secondary region without spaces"
  type        = string
}

variable "network_watcher_flow_log" {
  description = "Enable or disable network watcher flow log"
  type        = bool
}

variable "management_resources_tags" {
  description = "Map of tags for management resources"
  type        = map(string)
}

variable "security_alerts_email_address" {
  description = "Email address to receive security alerts"
  type        = string
}

variable "connectivity_subscription_id" {
  description = "Subscription ID for connectivity resources"
  type        = string
}

variable "identity_subscription_id" {
  description = "Subscription ID for identity resources"
  type        = string
}

variable "management_subscription_id" {
  description = "Subscription ID for management resources"
  type        = string
}


variable "log_analytics_workspace_id" {
  description = "Resource ID for the Log Analytics workspace"
  type        = string
}

variable "log_analytics_workspace_id_workspaceid" {
  description = "Workspace ID for the Log Analytics workspace"
  type        = string
}

variable "log_retention_in_days" {
  description = "log_retention_in_days"
  type        = string
}

variable "primary_default_route_ip" {
  description = "Default route IP for the primary network"
  type        = string
}

variable "secondary_default_route_ip" {
  description = "Default route IP for the secondary network"
  type        = string
}
variable "on_prem_networks" {
  description = "List of on-premises network IP addresses"
  type        = list(string)
}
variable "azure_all_networks" {
  description = "All Azure Networks"
  type        = string
}
variable "dc_primary_ip" {
  description = "All Azure Networks"
  type        = string
}
variable "dc_secondary_ip" {
  description = "All Azure Networks"
  type        = string
}


variable "on_prem_dc_ips" {
  description = "List of on-premises DC IP's"
  type        = list(string)
}

