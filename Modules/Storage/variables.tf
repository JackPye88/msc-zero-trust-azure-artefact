variable "st_name" {
  type        = string
  description = "The name of the route table."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the storage account."
}

variable "location" {
  type        = string
  description = "The location/region where the Storage Account is created."
  default     = "UK South"
}

variable "account_tier" {
  type        = string
  description = "The Account tier of the storage account"
  default     = "Standard"
}
variable "account_replication_type" {
  type        = string
  description = "The Replication type of the sotrage account"
}
variable "enable_hierarchical_namespace" {
  type        = string
  description = "enable_hierarchical_namespace"
  default     = false
}
variable "allow_nested_items_to_be_public" {
  type        = string
  description = "Allow nested items to be public"
  default     = false
}
variable "enable_https_traffic_only" {
  type        = string
  description = "Enable HTTPS traffic only"
  default     = true
}
variable "private_dns_zone" {
  type        = string
  description = "Enable HTTPS traffic only"
  default     = "privatelink.blob.core.windows.net"
}

variable "cross_tenant_replication_enabled" {
  type        = string
  description = "Enable cross tenant replication"
  default     = false
}
variable "shared_access_key_enabled" {
  type        = string
  description = "Shared Access Key Enabled"
  default     = false
}
variable "public_network_access_enabled" {
  type        = string
  description = "Public network access enabled"
  default     = false
}
variable "infrastructure_encryption_enabled" {
  type        = string
  description = "Enable encryption on infrastructure"
  default     = true
}
variable "min_tls_version" {
  type        = string
  description = "TLS Version"
  default     = "TLS1_2"
}

variable "versioning_enabled" {
  type        = string
  description = "Enable Versioning"
  default     = true
}
variable "change_feed_enabled" {
  type        = string
  description = "Enable change feed"
  default     = true
}

variable "change_feed_retention_in_days" {
  type        = string
  description = "Change feed retention"
  default     = 180
}
variable "blob_delete_retention_policy" {
  type        = string
  description = "blob Delete retention policy in days"
  default     = 90
}
variable "container_delete_retention_policy" {
  type        = string
  description = "Container delete retention policy in days"
  default     = 90
}

variable "key_vault" {
  description = "Customer Managed Key config"
  type        = object({ key_vault_id = string, key_vault_name = string, resource_group = string })
  default     = null
}

variable "managed_identity_type" {
  type        = string
  description = "Managed Identity type"
  default     = null

}
variable "default_action" {
  type        = string
  description = "Default action"
  default     = "Deny"

}



variable "pe_networking" {
  description = "Networking details for PE"
  type        = object({ subnet_id = string, vnet_name = string, vnet_rg_name = string, subnet_name = string, ip = string })
  default     = null
}


variable "tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags to assign to the resource"
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  type        = string
}
variable "private_endpoint_name" {
  type        = string
  description = "Private Endpoint Name"
  default     = null

}

variable "uks_pe_ip" {
  type        = string
  description = "UKS Private Endpoint IP"
  default     = null

}
variable "root_id" {
  type    = string
  default = "don"
}
variable "primary_short" {
  type    = string
  default = "uks"
}
variable "deploy_private_endpoint" {
  description = "Flag to deploy private endpoint"
  type        = bool
  default     = false
}

variable "deploy_cmk" {
  description = "Flag to deploy cmmk"
  type        = bool
  default     = true
}

