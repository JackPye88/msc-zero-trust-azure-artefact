resource "azurerm_backup_policy_vm" "this" {
  count                          = var.is_vm_backup ? 1 : 0
  name                           = replace(var.name, "TYPE", "VM")
  resource_group_name            = var.resource_group_name
  recovery_vault_name            = var.recovery_vault_name
  instant_restore_retention_days = 5

  timezone = "GMT Standard Time"

  backup {
    frequency = "Daily"
    time      = var.backup_time
  }

  retention_daily {
    count = var.retention_daily_count
  }

  retention_weekly {
    count    = var.retention_weekly_count
    weekdays = ["Sunday"]
  }

  dynamic "retention_monthly" {
    for_each = var.retention_monthly_count > 0 ? [1] : []
    content {
      count    = var.retention_monthly_count
      weekdays = ["Sunday"]
      weeks    = ["First"]
    }
  }

  dynamic "retention_yearly" {
    for_each = var.retention_yearly_count > 0 ? [1] : []
    content {
      count    = var.retention_yearly_count
      weekdays = ["Sunday"]
      weeks    = ["First"]
      months   = ["January"]
    }
  }
  instant_restore_resource_group {
    prefix = var.resource_group_name
  }
}

resource "azurerm_backup_policy_vm_workload" "sql" {
  count               = var.is_sql_backup ? 1 : 0
  name                = replace(var.name, "TYPE", "SQL")
  resource_group_name = var.resource_group_name
  recovery_vault_name = var.recovery_vault_name

  workload_type = "SQLDataBase"

  settings {
    time_zone           = "GMT Standard Time"
    compression_enabled = false
  }

  protection_policy {
    policy_type = "Full"

    backup {
      frequency = "Daily"
      time      = var.backup_time
    }

    retention_daily {
      count = var.retention_daily_count
    }
    retention_weekly {
      count    = var.retention_weekly_count
      weekdays = ["Sunday"]
    }

    dynamic "retention_monthly" {
      for_each = var.retention_monthly_count > 0 ? [1] : []
      content {
        count       = var.retention_monthly_count
        format_type = "Weekly"
        weekdays    = ["Sunday"]
        weeks       = ["First"]
      }
    }

    dynamic "retention_yearly" {
      for_each = var.retention_yearly_count > 0 ? [1] : []
      content {
        count       = var.retention_yearly_count
        format_type = "Weekly"
        weekdays    = ["Sunday"]
        weeks       = ["First"]
        months      = ["January"]
      }
    }
  }

  protection_policy {
    policy_type = "Log"

    backup {
      frequency_in_minutes = 120
    }

    simple_retention {
      count = 8
    }
  }
}

resource "azurerm_backup_policy_file_share" "this" {
  count               = var.is_files_backup ? 1 : 0
  name                = replace(var.name, "TYPE", "Files")
  resource_group_name = var.resource_group_name
  recovery_vault_name = var.recovery_vault_name

  timezone = "GMT Standard Time"

  backup {
    frequency = "Daily"
    time      = var.backup_time
  }

  retention_daily {
    count = var.retention_daily_count
  }

  retention_weekly {
    count    = var.retention_weekly_count
    weekdays = ["Sunday"]
  }

  dynamic "retention_monthly" {
    for_each = var.retention_monthly_count > 0 ? [1] : []
    content {
      count    = var.retention_monthly_count
      weekdays = ["Sunday"]
      weeks    = ["First"]
    }
  }

  dynamic "retention_yearly" {
    for_each = var.retention_yearly_count > 0 ? [1] : []
    content {
      count    = var.retention_yearly_count
      weekdays = ["Sunday"]
      weeks    = ["First"]
      months   = ["January"]
    }
  }
}
