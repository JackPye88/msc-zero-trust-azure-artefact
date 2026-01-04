
variable "deploy_management_resources" {
  description = "Flag to enable or disable the deployment of management resources"
  type        = bool
}

variable "rg_mgmt_automation_primary_001_enabled" {
  description = "Flag to enable the primary automation resource group"
  type        = bool
}

variable "rg_mgmt_backup_primary_001_enabled" {
  description = "Flag to enable the primary backup resource group"
  type        = bool
}

variable "rg_mgmt_management_primary_001_enabled" {
  description = "Flag to enable the primary management resource group"
  type        = bool
}

variable "rg_mgmt_keyvaultlz_primary_001_enabled" {
  description = "Flag to enable the primary Key Vault LZ resource group"
  type        = bool
}

variable "rg_mgmt_spoke_primary_001_enabled" {
  description = "Flag to enable the primary spoke resource group"
  type        = bool
}
variable "rg_mgmt_compute_primary_001_enabled" {
  description = "Flag to enable the primary Compute resource group"
  type        = bool
}
variable "rg_mgmt_storage_primary_001_enabled" {
  description = "Flag to enable the primary storage resource group"
  type        = bool
}

variable "mgmt_tfstate_storage_account_primary_enabled" {
  description = "Flag to enable the TFSTATE primary storage resource group"
  type        = bool
}


# Resource Groups in Secondary Region
variable "rg_mgmt_automation_secondary_001_enabled" {
  description = "Flag to enable the secondary automation resource group"
  type        = bool
}

variable "rg_mgmt_backup_secondary_001_enabled" {
  description = "Flag to enable the secondary backup resource group"
  type        = bool
}

variable "rg_mgmt_management_secondary_001_enabled" {
  description = "Flag to enable the secondary management resource group"
  type        = bool
}

variable "rg_mgmt_keyvaultlz_secondary_001_enabled" {
  description = "Flag to enable the secondary Key Vault LZ resource group"
  type        = bool
}

variable "rg_mgmt_spoke_secondary_001_enabled" {
  description = "Flag to enable the secondary spoke resource group"
  type        = bool
}
variable "rg_mgmt_compute_secondary_001_enabled" {
  description = "Flag to enable the secondary compute resource group"
  type        = bool
}
variable "rg_mgmt_storage_secondary_001_enabled" {
  description = "Flag to enable the secondary storage resource group"
  type        = bool
}

# Resource Groups Deployment Flags
variable "iden_domain_primary_rg_deploy" {
  description = "Flag to deploy the primary identity domain resource group"
  type        = bool
}

variable "iden_domain_secondary_rg_deploy" {
  description = "Flag to deploy the secondary identity domain resource group"
  type        = bool
}

variable "iden_spoke_primary_rg_deploy" {
  description = "Flag to deploy the primary identity spoke resource group"
  type        = bool
}

variable "iden_spoke_secondary_rg_deploy" {
  description = "Flag to deploy the secondary identity spoke resource group"
  type        = bool
}
