variable "root_id" {
  type        = string
  description = "The root identifier used for resource naming or other purposes."
}

variable "environment" {
  type        = string
  description = "The environment name (e.g., dev, prod, staging)."
}

variable "location_short" {
  type        = string
  description = "A short abbreviation for the location (e.g., 'eus' for East US)."
}


variable "location_long" {
  type        = string
  description = "The full name of the location/region (e.g., 'East US')."
}
variable "tags" {
  type        = map(string)
  default     = {}
  description = "A map of tags to assign to the resource."
}


variable "rg_descriptor" {
  type        = string
  description = "The full name of the location/region (e.g., 'East US')."
  default     = "mgmt"
}

variable "kvoverride" {
  type        = string
  default     = null
  description = "Optional override for the KV name"
}
variable "des_depends_on" {
  type        = any
  default     = null
  description = "Helps with dependencies."
}
variable "key_vault_id" {
  type        = string
  description = "KeyVaultID"
}