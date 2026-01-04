locals {
  environment               = "mgmt"
  environment_short         = "mgmt"
  subscription_id           = "de5384d3-5e48-4e83-936e-fdc62a27c9bf" # update
  primary_network_address   = "172.16.10.0/23"                       # update
  secondary_network_address = "172.16.138.0/23"                      # update
  subnet_prefix_bits        = "3"
  bastion_primary           = "172.16.26.0/23"                   # update
  bastion_secondary         = "172.16.154.0/23"                  # update
  az_dc_ips                 = ["172.16.2.132", "172.16.130.132"] # update

  budget_limit = 850 # update
  budget_notifications = [
    {
      enabled        = true
      operator       = "GreaterThan"
      threshold      = 90
      contact_emails = ["jack.pye@insight.com"]
      contact_roles  = ["Owner"]
    },
    {
      enabled        = true
      operator       = "GreaterThan"
      threshold      = 100
      contact_emails = ["jack.pye@insight.com"]
      contact_roles  = ["Owner"]
    },
    {
      enabled        = true
      operator       = "GreaterThan"
      threshold      = 110
      contact_emails = ["jack.pye@insight.com"]
      contact_roles  = ["Owner"]
    }
  ]


  lz_resource_groups = {
    spoke_RG = {
      rg_descriptor                = "spoke"
      deploy_primary               = true,
      deploy_delete_lock_primary   = false,
      deploy_secondary             = false,
      deploy_delete_lock_secondary = false,
    }
    mgmt_RG = {
      rg_descriptor                = "mgmt"
      deploy_primary               = true,
      deploy_delete_lock_primary   = false,
      deploy_secondary             = false,
      deploy_delete_lock_secondary = false,
    }
    storage_RG = {
      rg_descriptor                = "storage"
      deploy_primary               = true,
      deploy_delete_lock_primary   = false,
      deploy_secondary             = false,
      deploy_delete_lock_secondary = false,
    }
    kv_RG = {
      rg_descriptor                = "kv"
      deploy_primary               = true,
      deploy_delete_lock_primary   = false,
      deploy_secondary             = false,
      deploy_delete_lock_secondary = false,
    }
    comp_RG = {
      rg_descriptor                = "comp"
      deploy_primary               = true,
      deploy_delete_lock_primary   = false,
      deploy_secondary             = false,
      deploy_delete_lock_secondary = false,
    }
    apps_RG = {
      rg_descriptor                = "automation"
      deploy_primary               = true,
      deploy_delete_lock_primary   = false,
      deploy_secondary             = false,
      deploy_delete_lock_secondary = false,
    }
    monitoring_RG = {
      rg_descriptor                = "monitoring"
      deploy_primary               = false,
      deploy_delete_lock_primary   = false,
      deploy_secondary             = false,
      deploy_delete_lock_secondary = false,
    }

  }
  lz_spoke_vnets = {
    vnet1 = {
      vnet_descriptor        = "spoke"
      vnet_number            = "001"
      vnet_address_primary   = local.primary_network_address
      vnet_address_secondary = local.secondary_network_address

      deploy_primary   = true
      deploy_secondary = false
    }
  }
  lz_spoke_subnets = {

    mgmt_subnet = {
      subnet_descriptor        = "mgmt"
      vnet_descriptor          = "spoke"
      subnet_address_primary   = cidrsubnet(local.primary_network_address, local.subnet_prefix_bits, 0),
      subnet_address_secondary = cidrsubnet(local.secondary_network_address, local.subnet_prefix_bits, 0),
      deploy_primary           = true,
      deploy_secondary         = false,
      service_endpoints        = [] # Define service endpoints
      #      service_endpoints    = ["Microsoft.Storage", "Microsoft.Sql"] 
      service_delegation = []


    }
    pe_subnet = {
      subnet_descriptor        = "pe"
      vnet_descriptor          = "spoke"
      subnet_address_primary   = cidrsubnet(local.primary_network_address, local.subnet_prefix_bits, 1),
      subnet_address_secondary = cidrsubnet(local.secondary_network_address, local.subnet_prefix_bits, 1),

      deploy_primary     = true,
      deploy_secondary   = false,
      service_endpoints  = [] # Define service endpoints
      service_delegation = []


    }
    vm_subnet = {
      subnet_descriptor = "virtualmachines"
      vnet_descriptor   = "spoke"

      subnet_address_primary   = cidrsubnet(local.primary_network_address, local.subnet_prefix_bits, 2),
      subnet_address_secondary = cidrsubnet(local.secondary_network_address, local.subnet_prefix_bits, 2),

      deploy_primary     = true,
      deploy_secondary   = false,
      service_endpoints  = [] # Define service endpoints
      service_delegation = []



    }
    log_subnet = {
      subnet_descriptor = "log"
      vnet_descriptor   = "spoke"

      subnet_address_primary   = cidrsubnet(local.primary_network_address, local.subnet_prefix_bits, 3),
      subnet_address_secondary = cidrsubnet(local.secondary_network_address, local.subnet_prefix_bits, 3),

      deploy_primary     = true,
      deploy_secondary   = false,
      service_endpoints  = [] # Define service endpoints
      service_delegation = []



    }



  }
}