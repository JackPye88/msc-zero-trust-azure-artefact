# Read the CSV file from the same directory
data "local_file" "backup_policies_csv" {
  filename = "${path.module}/backup_policies.csv"
}

# Parse the CSV into a list of maps
locals {
  # Read and process CSV rows
  backup_policies_raw    = split("\n", trimspace(data.local_file.backup_policies_csv.content))
  backup_policies_header = split(",", local.backup_policies_raw[0])
  backup_policies_rows   = slice(local.backup_policies_raw, 1, length(local.backup_policies_raw))

  # Convert CSV rows into a list of maps
  backup_policies = [
    for row in local.backup_policies_rows : zipmap(
      local.backup_policies_header,
      split(",", row)
    )
  ]

  # Define backup times
  backup_times = ["21:00", "23:00", "01:00"]

  # Create combinations of backup policies and times
  prod_custom_backup_policies = flatten([
    for policy in local.backup_policies : [
      for backup_time in local.backup_times : {
        retention_yearly_count  = tonumber(policy.retention_yearly_count)
        retention_monthly_count = tonumber(policy.retention_monthly_count)
        retention_weekly_count  = tonumber(policy.retention_weekly_count)
        retention_daily_count   = tonumber(policy.retention_daily_count)
        backup_time             = backup_time
      }
    ]
  ])

  # Global configuration flags
  bpol_deploy_primary   = true
  bpol_deploy_secondary = false
  enable_vm_backup      = true
  enable_sql_backup     = true
  enable_files_backup   = true
}

# Primary Backup Modules
module "mgmt_custom_backup_primary" {
  for_each = {
    for idx, conf in local.prod_custom_backup_policies :
    "custom_primary_${conf.retention_yearly_count}year_${conf.retention_monthly_count}month_${conf.retention_weekly_count}week_${conf.retention_daily_count}day_${replace(conf.backup_time, ":", "")}" =>
    conf if local.bpol_deploy_primary
  }

  source                  = "../../Modules/Backup_Policy"
  name                    = "bkpol-${var.root_id}-TYPE-${each.value.retention_yearly_count}year-${each.value.retention_monthly_count}month-${each.value.retention_weekly_count}week-${each.value.retention_daily_count}day-${replace(each.value.backup_time, ":", "")}-${var.primary_short}-001"
  resource_group_name     = module.recovery_services_vault_primary["Base"].rsv_rg_name
  recovery_vault_name     = module.recovery_services_vault_primary["Base"].rsv_name
  backup_time             = each.value.backup_time
  retention_yearly_count  = each.value.retention_yearly_count
  retention_monthly_count = each.value.retention_monthly_count
  retention_daily_count   = each.value.retention_daily_count
  retention_weekly_count  = each.value.retention_weekly_count
  is_vm_backup            = local.enable_vm_backup
  is_sql_backup           = local.enable_sql_backup
  is_files_backup         = local.enable_files_backup
}

# Secondary Backup Modules
module "mgmt_custom_backup_secondary" {
  for_each = {
    for idx, conf in local.prod_custom_backup_policies :
    "custom_secondary_${conf.retention_yearly_count}year_${conf.retention_monthly_count}month_${conf.retention_weekly_count}week_${conf.retention_daily_count}day_${replace(conf.backup_time, ":", "")}" =>
    conf if local.bpol_deploy_secondary
  }

  source                  = "../../Modules/Backup_Policy"
  name                    = "bkpol-${var.root_id}-TYPE-${each.value.retention_yearly_count}year-${each.value.retention_monthly_count}month-${each.value.retention_weekly_count}week-${each.value.retention_daily_count}day-${replace(each.value.backup_time, ":", "")}-${var.secondary_short}-001"
  resource_group_name     = module.recovery_services_vault_secondary["Base"].rsv_rg_name
  recovery_vault_name     = module.recovery_services_vault_secondary["Base"].rsv_name
  backup_time             = each.value.backup_time
  retention_yearly_count  = each.value.retention_yearly_count
  retention_monthly_count = each.value.retention_monthly_count
  retention_daily_count   = each.value.retention_daily_count
  retention_weekly_count  = each.value.retention_weekly_count
  is_vm_backup            = local.enable_vm_backup
  is_sql_backup           = local.enable_sql_backup
  is_files_backup         = local.enable_files_backup
}
