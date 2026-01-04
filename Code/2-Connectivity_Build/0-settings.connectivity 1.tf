# Configure the connectivity resources settings.
locals {
  configure_connectivity_resources = {
    settings = {
      hub_networks = [
        {
          enabled = true
          config = {
            address_space                = [var.hub_net_address_primary, ]
            location                     = var.primary_long_no_space
            link_to_ddos_protection_plan = false
            dns_servers                  = [var.DNS_server_primary_1, var.DNS_server_primary_2]
            bgp_community                = ""
            subnets = [
              {
                name                      = "AzureBastionSubnet"
                address_prefixes          = [var.bastion_subnet_address_primary]
                network_security_group_id = null
                route_table_id            = null
              },
            ]
            virtual_network_gateway = {
              enabled = var.enable_primary_vnet_gateway
              config = {
                address_prefix           = var.virtual_network_gateway_subnet_address_primary
                gateway_sku_expressroute = var.express_route_sku
                gateway_sku_vpn          = var.vpn_sku_primary
                advanced_vpn_settings = {
                  enable_bgp                       = null
                  active_active                    = null
                  private_ip_address_allocation    = ""
                  default_local_network_gateway_id = ""
                  vpn_client_configuration         = []
                  bgp_settings                     = []
                  custom_route                     = []
                }
              }
            }
            azure_firewall = {
              enabled = var.enable_primary_afw
              config = {
                address_prefix                = var.afw_subnet_address_primary
                enable_dns_proxy              = false
                dns_servers                   = []
                sku_tier                      = var.afw_sku
                base_policy_id                = ""
                private_ip_ranges             = []
                threat_intelligence_mode      = ""
                threat_intelligence_allowlist = {}
                availability_zones = {
                  zone_1 = var.availibility_zone_1_enabled_primary
                  zone_2 = var.availibility_zone_2_enabled_primary
                  zone_3 = var.availibility_zone_3_enabled_primary
                }
              }
            }
            spoke_virtual_network_resource_ids      = []
            enable_outbound_virtual_network_peering = true
            enable_hub_network_mesh_peering         = false
          }
        },
        {
          enabled = true
          config = {
            address_space                = [var.hub_net_address_secondary, ]
            location                     = var.secondary_long_no_space
            link_to_ddos_protection_plan = false
            dns_servers                  = [var.DNS_server_secondary_1, var.DNS_server_secondary_2]
            bgp_community                = ""
            subnets = [{
              name                      = "AzureBastionSubnet"
              address_prefixes          = [var.bastion_subnet_address_secondary]
              network_security_group_id = null
              route_table_id            = null
            }]
            virtual_network_gateway = {
              enabled = var.enable_secondary_vnet_gateway
              config = {
                address_prefix           = var.virtual_network_gateway_subnet_address_secondary
                gateway_sku_expressroute = var.express_route_sku_secondary
                gateway_sku_vpn          = var.vpn_sku_secondary
                advanced_vpn_settings = {
                  enable_bgp                       = null
                  active_active                    = null
                  private_ip_address_allocation    = ""
                  default_local_network_gateway_id = ""
                  vpn_client_configuration         = []
                  bgp_settings                     = []
                  custom_route                     = []
                }
              }
            }
            azure_firewall = {
              enabled = var.enable_secondary_afw
              config = {
                address_prefix                = var.afw_subnet_address_secondary
                enable_dns_proxy              = false
                dns_servers                   = []
                sku_tier                      = var.afw_sku
                base_policy_id                = ""
                private_ip_ranges             = []
                threat_intelligence_mode      = ""
                threat_intelligence_allowlist = {}
                availability_zones = {
                  zone_1 = var.availibility_zone_1_enabled_secondary
                  zone_2 = var.availibility_zone_2_enabled_secondary
                  zone_3 = var.availibility_zone_3_enabled_secondary
                }
              }
            }
            spoke_virtual_network_resource_ids      = []
            enable_outbound_virtual_network_peering = true
            enable_hub_network_mesh_peering         = false
          }
        },
      ]
      vwan_hub_networks = []
      ddos_protection_plan = {
        enabled = false
        config = {
          location = var.secondary_long
        }
      }
      dns = {
        enabled = true
        config = {
          location = var.primary_long_no_space
          enable_private_link_by_service = {
            azure_api_management                 = true
            azure_app_configuration_stores       = true
            azure_arc                            = true
            azure_automation_dscandhybridworker  = true
            azure_automation_webhook             = true
            azure_backup                         = true
            azure_batch_account                  = true
            azure_bot_service_bot                = true
            azure_bot_service_token              = true
            azure_cache_for_redis                = true
            azure_cache_for_redis_enterprise     = true
            azure_container_registry             = true
            azure_cosmos_db_cassandra            = true
            azure_cosmos_db_gremlin              = true
            azure_cosmos_db_mongodb              = true
            azure_cosmos_db_sql                  = true
            azure_cosmos_db_table                = true
            azure_data_explorer                  = false
            azure_data_factory                   = true
            azure_data_factory_portal            = true
            azure_data_health_data_services      = true
            azure_data_lake_file_system_gen2     = true
            azure_database_for_mariadb_server    = true
            azure_database_for_mysql_server      = true
            azure_database_for_postgresql_server = true
            azure_digital_twins                  = true
            azure_event_grid_domain              = true
            azure_event_grid_topic               = true
            azure_event_hubs_namespace           = true
            azure_file_sync                      = true
            azure_hdinsights                     = true
            azure_iot_dps                        = true
            azure_iot_hub                        = true
            azure_key_vault                      = true
            azure_key_vault_managed_hsm          = true
            azure_kubernetes_service_management  = false
            azure_machine_learning_workspace     = true
            azure_managed_disks                  = true
            azure_media_services                 = true
            azure_migrate                        = true
            azure_monitor                        = true
            azure_purview_account                = true
            azure_purview_studio                 = true
            azure_relay_namespace                = true
            azure_search_service                 = true
            azure_service_bus_namespace          = true
            azure_site_recovery                  = true
            azure_sql_database_sqlserver         = true
            azure_synapse_analytics_dev          = true
            azure_synapse_analytics_sql          = true
            azure_synapse_studio                 = true
            azure_web_apps_sites                 = true
            azure_web_apps_static_sites          = true
            cognitive_services_account           = true
            microsoft_power_bi                   = true
            signalr                              = true
            signalr_webpubsub                    = true
            storage_account_blob                 = true
            storage_account_file                 = true
            storage_account_queue                = true
            storage_account_table                = true
            storage_account_web                  = true
          }
          private_link_locations = [
            var.primary_long,
            var.secondary_long,
          ]
          public_dns_zones                                       = []
          private_dns_zones                                      = []
          enable_private_dns_zone_virtual_network_link_on_hubs   = true
          enable_private_dns_zone_virtual_network_link_on_spokes = true
          virtual_network_resource_ids_to_link                   = []
        }
      }
    }

    location = var.primary_long
    tags     = var.management_resources_tags
    advanced = {
      custom_settings_by_resource_type = {
        azurerm_resource_group = {
          connectivity = {
            (var.primary_long_no_space) = {
              name = "rg-${var.root_id}-con-hub-${var.primary_short}-001"
            }
            (var.secondary_long_no_space) = {
              name = "rg-${var.root_id}-con-hub-${var.secondary_short}-001"
            }
          }
          dns = {
            (var.primary_long_no_space) = {
              name = "rg-${var.root_id}-con-dns-${var.primary_short}-001"
            }
          }
        },
        azurerm_firewall = {
          connectivity = {
            (var.primary_long_no_space) = {
              name = "afw-${var.root_id}-con-hub-${var.primary_short}-001"
            }

            (var.secondary_long_no_space) = {
              name = "afw-${var.root_id}-con-hub-${var.secondary_short}-001"

              firewall_policy_id = "/subscriptions/${var.connectivity_subscription_id}/resourceGroups/rg-${var.root_id}-con-hub-uks-001/providers/Microsoft.Network/firewallPolicies/afwpol-${var.root_id}-con-hub-uks-001"

              # firewall_policy_id = "/subscriptions/${var.connectivity_subscription_id}/resourceGroups/rg-${var.root_id}-con-hub-${var.primary_short}-001/providers/Microsoft.Network/firewallPolicies/afwpol-${var.root_id}-con-hub-${var.primary_short}-001"
            }
          }
        },
        azurerm_virtual_network = {
          connectivity = {
            (var.primary_long_no_space) = {
              name = "vnet-${var.root_id}-con-hub-${var.primary_short}-001"
            }
            (var.secondary_long_no_space) = {
              name = "vnet-${var.root_id}-con-hub-${var.secondary_short}-001"
            }
          }
        },
        azurerm_virtual_network_gateway = {
          connectivity_expressroute = {
            (var.primary_long_no_space) = {
              name = "ergw-${var.root_id}-con-hub-${var.primary_short}-001"
            }
            (var.secondary_long_no_space) = {
              name = "vngw-${var.root_id}-con-hub-${var.secondary_short}-001"
            }

          }
          connectivity_vpn = {
            (var.primary_long_no_space) = {
              name = "vng-${var.root_id}-con-hub-${var.primary_short}-001"
            }
            (var.secondary_long_no_space) = {
              name = "vng-${var.root_id}-con-hub-${var.secondary_short}-001"
            }
          }
        },
        azurerm_public_ip = {
          connectivity_firewall = {
            (var.primary_long_no_space) = {
              name = "pip-${var.root_id}-con-afw-${var.primary_short}-001"
            }
            (var.secondary_long_no_space) = {
              name = "pip-${var.root_id}-con-afw-${var.secondary_short}-001"
            }
          },
          connectivity_expressroute = {
            (var.primary_long_no_space) = {
              name = "pip-${var.root_id}-con-ergw-${var.primary_short}-001"
            }
            (var.secondary_long_no_space) = {
              name = "pip-${var.root_id}-con-vngw-${var.secondary_short}-001"
            }
          },
          connectivity_vpn = {
            (var.primary_long_no_space) = {
              name              = "pip-${var.root_id}-con-hubvg-${var.primary_short}-001"
              sku               = "Standard"
              allocation_method = "Static"
            }
            (var.secondary_long_no_space) = {
              name              = "pip-${var.root_id}-con-hubvg-${var.secondary_short}-001"
              sku               = "Standard"
              allocation_method = "Static"
            }
          }
        },

        azurerm_firewall_policy = {
          connectivity = {
            (var.primary_long_no_space) = {
              name = "afwpol-${var.root_id}-con-hub-${var.primary_short}-001"
              dns = [
                {
                  proxy_enabled = true
                  servers       = ["172.16.2.132"]
                }
              ]
            }
            (var.secondary_long_no_space) = {
              name = "afwpol-${var.root_id}-con-hub-${var.primary_short}-001"
            }
          }
        },
      }
    }
  }
}