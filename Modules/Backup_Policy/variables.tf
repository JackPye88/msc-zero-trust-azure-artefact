variable "name" {
  description = "The name of the backup policy"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "recovery_vault_name" {
  description = "The name of the Recovery Services vault"
  type        = string
}

variable "backup_time" {
  description = "The time of the backup in HH:MM format"
  type        = string
}

variable "retention_yearly_count" {
  description = "The number of years to retain backups"
  type        = number
}

variable "retention_daily_count" {
  description = "The number of days to retain backups"
  type        = number
  default     = 30
}

variable "retention_weekly_count" {
  description = "The number of weeks to retain backups"
  type        = number
  default     = 4
}

variable "retention_monthly_count" {
  description = "The number of months to retain backups"
  type        = number
  default     = 12
}

variable "is_vm_backup" {
  description = "Flag to determine if the backup is for a VM"
  type        = bool
  default     = false
}

variable "is_sql_backup" {
  description = "Flag to determine if the backup is for SQL"
  type        = bool
  default     = false
}

variable "is_files_backup" {
  description = "Flag to determine if the backup is for Azure Files"
  type        = bool
  default     = false
}
