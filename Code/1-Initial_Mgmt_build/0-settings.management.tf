# Configure the management resources settings.
locals {
  configure_management_resources = {

    settings = {
      ama = {
        enable_uami                                                         = true
        enable_vminsights_dcr                                               = true
        enable_change_tracking_dcr                                          = true
        enable_mdfc_defender_for_sql_dcr                                    = false
        enable_mdfc_defender_for_sql_query_collection_for_security_research = false
      }
      log_analytics = {
        enabled = true
        config = {
          retention_in_days                                 = var.log_retention_in_days
          enable_monitoring_for_vm                          = true
          enable_monitoring_for_vmss                        = true
          enable_solution_for_agent_health_assessment       = true
          enable_solution_for_anti_malware                  = true
          enable_solution_for_change_tracking               = true
          enable_solution_for_service_map                   = true
          enable_solution_for_sql_assessment                = true
          enable_solution_for_sql_vulnerability_assessment  = true
          enable_solution_for_sql_advanced_threat_detection = true
          enable_solution_for_updates                       = true
          enable_solution_for_vm_insights                   = true
          enable_solution_for_container_insights            = true
          enable_sentinel                                   = false
        }
      }
      security_center = {
        enabled = false
        config = {
          email_security_contact                                = var.security_alerts_email_address
          enable_defender_for_apis                              = true
          enable_defender_for_app_services                      = true
          enable_defender_for_arm                               = true
          enable_defender_for_containers                        = true
          enable_defender_for_cosmosdbs                         = true
          enable_defender_for_cspm                              = true
          enable_defender_for_dns                               = true
          enable_defender_for_key_vault                         = true
          enable_defender_for_oss_databases                     = true
          enable_defender_for_servers                           = true
          enable_defender_for_servers_vulnerability_assessments = true
          enable_defender_for_sql_servers                       = true
          enable_defender_for_sql_server_vms                    = true
          enable_defender_for_storage                           = true
        }
      }
    }

    location = var.primary_long_no_space_lower
    tags     = var.management_resources_tags


    advanced = {
      custom_settings_by_resource_type = {
        azurerm_resource_group = {
          management = {
            name = "rg-${var.root_id}-mgmt-monitoring-${var.primary_short}-001"

          }
        },

        azurerm_log_analytics_workspace = {
          management = {
            name                       = "law-${var.root_id}-mgmt-monitor-${var.primary_short}-001"
            internet_ingestion_enabled = false
          }
        },
        azurerm_automation_account = {
          management = {
            name = "aa-${var.root_id}-mgmt-${var.primary_short}-001"
            #resource_group_name = "rg-${var.root_id}-mgmt-automation-${var.primary_short}-001"
            public_network_access_enabled = false
          }
        }
      }
    }
  }


}