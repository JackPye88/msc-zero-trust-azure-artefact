variable "name" {
  description = "The name of the firewall policy rule collection group."
  type        = string
}

variable "firewall_policy_id" {
  description = "The ID of the firewall policy to which this rule collection group belongs."
  type        = string
}
variable "on_prem_networks" {
  description = "List of on-premises network IP addresses"
  type        = list(string)
}

variable "azure_all_networks" {
  description = "The ID of the firewall policy to which this rule collection group belongs."
  type        = string
}
variable "rule_descriptor" {
  description = "The ID of the firewall policy to which this rule collection group belongs."
  type        = string
}
variable "primary_region_address" {
  description = "The ID of the firewall policy to which this rule collection group belongs."
  type        = string
}
variable "secondary_region_address" {
  description = "The ID of the firewall policy to which this rule collection group belongs."
  type        = string
  default     = "10.10.10.1"
}
variable "priority" {
  description = "The priority of the rule collection group."
  type        = number
}

variable "nsg_base_priority" {
  description = "The base priority for the NSG rules."
  type        = number
  default     = 1000
}

variable "primary_nsg_name" {
  description = "The name of the primary network security group."
  type        = string
}

variable "secondary_nsg_name" {
  description = "The name of the secondary network security group."
  type        = string
}

variable "deploy_secondary" {
  description = "Boolean to indicate whether to deploy rules to the secondary NSG."
  type        = bool
  default     = false
}

variable "primary_nsg_resource_group_name" {
  description = "The name of the resource group for the primary NSG."
  type        = string
}

variable "secondary_nsg_resource_group_name" {
  description = "The name of the resource group for the secondary NSG."
  type        = string
}

variable "network_rule_collections" {
  description = "A list of network rule collections."
  type = list(object({
    name     = string
    priority = number
    action   = string

    rules = list(object({
      name                         = string
      fw_deploy                    = bool
      direction                    = string
      protocols                    = list(string)
      primary_region_address       = optional(list(string), [])
      secondary_region_address     = optional(list(string), [])
      primary_region_source        = optional(list(string), [])
      secondary_region_source      = optional(list(string), [])
      primary_region_destination   = optional(list(string), [])
      secondary_region_destination = optional(list(string), [])
      source_addresses             = list(string)
      destination_ports            = list(string)
      destination_addresses        = list(string)
    }))
  }))
  default = []
}

variable "application_rule_collections" {
  description = "A list of application rule collections."
  type = list(object({
    name     = string
    priority = number
    action   = string
    rules = list(object({
      name              = string
      source_addresses  = list(string)
      destination_fqdns = list(string)
      protocols = list(object({
        type = string
        port = number
      }))
    }))
  }))
  default = []
}
