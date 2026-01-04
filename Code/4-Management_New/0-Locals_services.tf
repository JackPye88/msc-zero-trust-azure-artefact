locals {

  KeyVault = {
    001 = {
      identifier       = "001"
      deploy_primary   = true
      primary_ip       = cidrhost(cidrsubnet(local.primary_network_address, local.subnet_prefix_bits, 1), 13)
      deploy_secondary = false
      secondary_ip     = cidrhost(cidrsubnet(local.secondary_network_address, local.subnet_prefix_bits, 1), 13)
      # ip_rules = []
      ip_rules = ["81.110.239.152/32"]

    }

  }
  automation_account = {
    Base = {
      deploy_primary   = false
      primary_ip_1     = cidrhost(cidrsubnet(local.primary_network_address, local.subnet_prefix_bits, 1), 20)
      primary_ip_2     = cidrhost(cidrsubnet(local.primary_network_address, local.subnet_prefix_bits, 1), 21)
      deploy_secondary = false
      secondary_ip_1   = cidrhost(cidrsubnet(local.secondary_network_address, local.subnet_prefix_bits, 1), 20)
      secondary_ip_2   = cidrhost(cidrsubnet(local.secondary_network_address, local.subnet_prefix_bits, 1), 21)

    }
  }
  disk_encryption_set = {
    Base = {
      deploy_primary   = true
      deploy_secondary = false
    }
  }
  recovery_services_vault = {
    Base = {
      deploy_primary   = true
      primary_ip_1     = cidrhost(cidrsubnet(local.primary_network_address, local.subnet_prefix_bits, 1), 57)
      primary_ip_2     = cidrhost(cidrsubnet(local.primary_network_address, local.subnet_prefix_bits, 1), 58)
      primary_ip_3     = cidrhost(cidrsubnet(local.primary_network_address, local.subnet_prefix_bits, 1), 59)
      primary_ip_4     = cidrhost(cidrsubnet(local.primary_network_address, local.subnet_prefix_bits, 1), 60)
      primary_ip_5     = cidrhost(cidrsubnet(local.primary_network_address, local.subnet_prefix_bits, 1), 61)
      deploy_secondary = false
      secondary_ip_1   = cidrhost(cidrsubnet(local.secondary_network_address, local.subnet_prefix_bits, 1), 57)
      secondary_ip_2   = cidrhost(cidrsubnet(local.secondary_network_address, local.subnet_prefix_bits, 1), 58)
      secondary_ip_3   = cidrhost(cidrsubnet(local.secondary_network_address, local.subnet_prefix_bits, 1), 59)
      secondary_ip_4   = cidrhost(cidrsubnet(local.secondary_network_address, local.subnet_prefix_bits, 1), 60)
      secondary_ip_5   = cidrhost(cidrsubnet(local.secondary_network_address, local.subnet_prefix_bits, 1), 61)

    }
  }

  # Backup Configuration
  backup_times          = ["21:00", "23:00", "01:00"] # Update thos for the start time of the backup.
  bpol_deploy_primary   = true
  bpol_deploy_secondary = false
  enable_vm_backup      = true
  enable_sql_backup     = true
  enable_files_backup   = true

  maintenance_configs = {
    "1sat_post_pt_23:00" = {
      start_time  = "23:00"
      recur_every = "Month Second Tuesday Offset4"
      tag_value   = "first_saturday_after_patch_tuesday"
    }
    "2sat_post_pt_23:00" = {
      start_time  = "23:00"
      recur_every = "Month Third Tuesday Offset4"
      tag_value   = "second_saturday_after_patch_tuesday"
    }
    "3sat_post_pt_23:00" = {
      start_time  = "23:00"
      recur_every = "Month Third Tuesday Offset4"
      tag_value   = "third_saturday_after_patch_tuesday"
    }
  }

  asr_cache = {
    Base = {
      deploy_primary   = true
      primary_ip       = cidrhost(cidrsubnet(local.primary_network_address, local.subnet_prefix_bits, 1), 16)
      deploy_secondary = false
      secondary_ip     = cidrhost(cidrsubnet(local.secondary_network_address, local.subnet_prefix_bits, 1), 16)

    }
  }
  shared_storage = {
    shared = {
      descriptor                         = "log"
      enable_hierarchical_namespace      = false
      deploy_primary                     = true
      primary_ip                         = cidrhost(cidrsubnet(local.primary_network_address, local.subnet_prefix_bits, 1), 17)
      account_replication_type_primary   = "ZRS"
      deploy_secondary                   = false
      secondary_ip                       = cidrhost(cidrsubnet(local.secondary_network_address, local.subnet_prefix_bits, 1), 17)
      account_replication_type_secondary = "LRS"

      change_feed_retention_days        = 30 # 
      blob_delete_retention_policy      = 30 # 
      container_delete_retention_policy = 30 # 
    }
    asrcache = {
      descriptor                       = "asrcache"
      enable_hierarchical_namespace    = false
      deploy_primary                   = true
      primary_ip                       = cidrhost(cidrsubnet(local.primary_network_address, local.subnet_prefix_bits, 1), 19)
      account_replication_type_primary = "LRS"

      deploy_secondary                   = false
      secondary_ip                       = cidrhost(cidrsubnet(local.secondary_network_address, local.subnet_prefix_bits, 1), 19)
      account_replication_type_secondary = "LRS"
      shared_access_key_enabled          = true
      versioning_enabled                 = false
      change_feed_enabled                = false
      change_feed_retention_days         = 0 # 
      blob_delete_retention_policy       = 0 # 
      container_delete_retention_policy  = 0 # 
    }
    tfstate = {
      descriptor                         = "tfstate"
      enable_hierarchical_namespace      = false
      deploy_primary                     = true
      public_network_access_enabled      = true
      primary_ip                         = cidrhost(cidrsubnet(local.primary_network_address, local.subnet_prefix_bits, 1), 21)
      account_replication_type_primary   = "LRS"
      deploy_secondary                   = false
      secondary_ip                       = cidrhost(cidrsubnet(local.secondary_network_address, local.subnet_prefix_bits, 1), 21)
      account_replication_type_secondary = "LRS"

      change_feed_retention_days        = 30 # 
      blob_delete_retention_policy      = 30 # 
      container_delete_retention_policy = 30 # 
    }


  }


}