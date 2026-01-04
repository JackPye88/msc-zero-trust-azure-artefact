variable "environment" {
  type        = string
  description = "Deployment environment name"
}

variable "environment_short" {
  type        = string
  description = "Abbreviated name used in naming conventions"
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "primary_network_address" {
  type        = string
  description = "Primary CIDR block for virtual networking"
}

variable "secondary_network_address" {
  type        = string
  description = "Secondary CIDR block for virtual networking"
}

variable "subnet_prefix_bits" {
  type        = number
  description = "CIDR subnet prefix used for address splitting"
}

variable "bastion_primary" {
  type        = string
  description = "Primary Bastion subnet CIDR"
}

variable "bastion_secondary" {
  type        = string
  description = "Secondary Bastion subnet CIDR"
}

variable "az_dc_ips" {
  type        = list(string)
  description = "List of DC IP addresses"
}

variable "budget_limit" {
  type        = number
  description = "Spending threshold for cost management"
}

variable "instance" {
  type        = number
  description = "Numeric identifier for deployment instance"
}

variable "lz_resource_groups" {
  type = map(object({
    rg_descriptor    = string
    deploy_primary   = bool
    deploy_secondary = bool
  }))
  description = "Logical zone resource group configuration"
}

variable "lz_spoke_vnets" {
  type = map(object({
    vnet_descriptor        = string
    vnet_number            = string
    vnet_address_primary   = string
    vnet_address_secondary = string
    deploy_primary         = bool
    deploy_secondary       = bool
  }))
  description = "Logical zone spoke VNet definitions"
}

variable "lz_spoke_subnets" {
  type = map(object({
    subnet_descriptor    = string
    vnet_descriptor      = string
    subnet_index         = number
    deploy_primary       = bool
    subnet_prefix_bits   = number
    deploy_secondary     = bool
    deny_all_outbound    = bool
    default_route_deploy = bool

    service_endpoints = list(string)
    service_delegation = list(object({
      name    = string
      actions = list(string)
    }))
  }))
  description = "Spoke subnet definitions with delegation and endpoints"
}



# 🧱 Key Vaults
variable "key_vaults" {
  type = map(object({
    identifier       = string
    deploy_primary   = bool
    deploy_secondary = bool
    ip_offset        = number
    ip_rules         = list(string)
  }))
  description = "Key Vault deployment settings"
}

# ⚙️ Automation Accounts
variable "automation_accounts" {
  type = map(object({
    deploy_primary   = bool
    deploy_secondary = bool
    ip_offset_1      = number
    ip_offset_2      = number
  }))
}

# 🛡️ Disk Encryption Sets
variable "disk_encryption_sets" {
  type = map(object({
    deploy_primary   = bool
    deploy_secondary = bool
  }))
}

# ♻️ Recovery Services Vaults
variable "recovery_services_vaults" {
  type = map(object({
    deploy_primary   = bool
    deploy_secondary = bool
    ip_offsets       = list(number)
  }))
}

# 📁 ASR Cache
variable "asr_caches" {
  type = map(object({
    deploy_primary   = bool
    deploy_secondary = bool
    ip_offset        = number
  }))
}

# 📦 Shared Storage
variable "shared_storage_accounts" {
  type = map(object({
    descriptor                         = string
    enable_hierarchical_namespace      = bool
    deploy_primary                     = bool
    deploy_secondary                   = bool
    ip_offset                          = number
    account_replication_type_primary   = string
    account_replication_type_secondary = string
    shared_access_key_enabled          = optional(bool, false)
    versioning_enabled                 = optional(bool, false)
    change_feed_enabled                = optional(bool, false)
    change_feed_retention_days         = optional(number, 0)
    blob_delete_retention_policy       = optional(number, 0)
    container_delete_retention_policy  = optional(number, 0)
    private_dns_zone                   = optional(string, "privatelink.blob.core.windows.net")
  }))
}

# 🖥️ Virtual Machines
variable "virtual_machines" {
  type = map(object({
    vm_descriptor    = string
    vm_number        = string
    deploy_primary   = bool
    deploy_secondary = bool
    ip_offset        = number
    enable_aad_join  = bool
    server_os        = string
    sku              = string
    role             = string
    Application      = string
    DR               = string
    Backup           = string
    vmupdate         = string
    data_disks = list(object({
      name                 = string
      size                 = number
      storage_account_type = string
    }))
  }))
}

# 📊 Application Insights
variable "application_insights" {
  type = map(object({
    deploy_primary    = bool
    deploy_secondary  = bool
    primary_offsets   = list(number)
    secondary_offsets = list(number)
  }))
}

variable "kv_base_build_custom_primary_ip" {
  type        = list(string)
  description = "list of custom static ips for kv base build in primary region"
  default     = []
}

variable "kv_base_build_custom_secondary_ip" {
  type        = list(string)
  description = "list of custom static ips for kv base build in secondary region"
  default     = []
}
variable "aad_groups" {
  type = map(object({
    prefix      = string # Prefix like "Azure", "DBW", etc.
    name_suffix = string # Suffix like "Level_2", "CATALOG_ADMINS", etc.
    description = string
    role_assignments = optional(list(object({
      role_name      = string
      scope          = string
      provider_alias = optional(string)
    })), [])
  }))
  description = "Custom AAD group definitions"
}

variable "sg_name_environment" {
  description = "Short suffix for environment (e.g. Forge_UAT)"
  type        = string
}

variable "management_group_name" {
  description = "Name of the Azure management group for role assignment"
  type        = string
}

variable "dns_resource_group_name" {
  description = "Name of the DNS resource group used for connectivity scope"
  type        = string
}

variable "kv_rules_priority" {
  description = "rule priority for KV Rules"
  type        = number

}