

locals {
  #bastion_primary = "172.16.0.128/26"
  #bastion_secondary = "172.16.128.128/26"
  linux_virtual_machines = {
    ## Primary
    sha = {
      vm_descriptor        = "sha" # Total length cant be more then 15 charachters
      vm_number            = "2"
      ip_address_primary   = "172.16.10.140"
      ip_address_secondary = ""
      deploy_primary       = true
      deploy_secondary     = false
      server_os            = "22_04-lts" # for 2022 DC use (2022-Datacenter)for 2019 DC use (2019-Datacenter) for 2012 R2 DC use (2012-R2-Datacenter)
      sku                  = "Standard_D2s_v3"
      role                 = "Linux Azure DevOps Self Hosted Agent"
      Application          = "Azure DevOps Self Hosted Agent"
      DR                   = "Not Required"
      Backup               = "Not Required"
      vmupdate             = "first_saturday_after_patch_tuesday"
      data_disks           = []
      /*data_disks     = [
        {
          name                 = "datadisk1"
          size                 = 128
          storage_account_type = "Standard_LRS"
        },
        {
          name                 = "datadisk2"
          size                 = 256
          storage_account_type = "Premium_LRS"
        }
      ]
    */
    }




  }

}

module "deploy_linux_primary_vm" {
  source = "../../Modules/Linux_Virtual_Machine"

  providers = {
    azurerm.main         = azurerm
    azurerm.connectivity = azurerm.connectivity
  }

  # Use for_each to handle both primary and secondary configurations
  for_each = merge(
    { for key, value in local.linux_virtual_machines :
      "${key}" => {
        location    = "primary",
        ip_address  = value.ip_address_primary,
        descriptor  = value.vm_descriptor,
        sku         = value.sku,
        vm_number   = value.vm_number,
        server_os   = value.server_os,
        bastion_ip  = local.bastion_primary,
        deploy_flag = value.deploy_primary
        data_disks  = value.data_disks
        role        = value.role
        Application = value.Application
        DR          = value.DR
        Backup      = value.Backup
        vmupdate    = value.vmupdate
    } if value.deploy_primary == true },

    { for key, value in local.linux_virtual_machines :
      "${key}-secondary" => {
        location    = "secondary",
        ip_address  = value.ip_address_secondary,
        descriptor  = value.vm_descriptor,
        sku         = value.sku,
        vm_number   = value.vm_number,
        server_os   = value.server_os,
        bastion_ip  = local.bastion_secondary,
        deploy_flag = value.deploy_secondary
        data_disks  = value.data_disks
        role        = value.role
        Application = value.Application
        DR          = value.DR
        Backup      = value.Backup
        vmupdate    = value.vmupdate
    } if value.deploy_secondary == true }
  )

  vm_name  = "vm${var.root_id}${each.value.descriptor}${each.value.location == "primary" ? var.primary_short : var.secondary_short}${each.value.vm_number}"
  sku      = each.value.sku
  location = each.value.location == "primary" ? var.primary_long : var.secondary_long

  resource_group_name = "rg-${var.root_id}-${local.environment}-comp-${each.value.location == "primary" ? var.primary_short : var.secondary_short}-001"
  des_name            = "des-${var.root_id}-${local.environment}-${each.value.location == "primary" ? var.primary_short : var.secondary_short}-001"
  des_rg              = "rg-${var.root_id}-${local.environment}-mgmt-${each.value.location == "primary" ? var.primary_short : var.secondary_short}-001"

  root_id                  = var.root_id
  private_ip_address       = each.value.ip_address
  subnetname               = "snet-${local.environment}-virtualmachines-${each.value.location == "primary" ? var.primary_short : var.secondary_short}-001"
  virtual_network_name     = "vnet-${var.root_id}-${local.environment}-spoke-${each.value.location == "primary" ? var.primary_short : var.secondary_short}-001"
  snet_resource_group_name = "rg-${var.root_id}-${local.environment}-spoke-${each.value.location == "primary" ? var.primary_short : var.secondary_short}-001"

  server_os  = each.value.server_os
  bastion_ip = each.value.bastion_ip

  tags = merge(
    var.management_resources_tags,
    {
      AZUpdate = try(each.value.vmupdate, ""),
      Role     = try(each.value.role, ""),
      #environment = local.environment,
      Application = try(each.value.Application, ""),
      DR          = try(each.value.DR, ""),
      AZBackup    = try(each.value.Backup, "")
    }
  )

  #depends_on = [module.subnet_creation]
  data_disks = each.value.data_disks
}



/*
module "deploy_primary_vm" {

  source = "../Modules/Virtual_Machine"
  providers = {
    azurerm.main         = azurerm
    azurerm.connectivity = azurerm.connectivity
  }
  for_each                 = { for key, value in local.virtual_machines : key => value if value.deploy_primary == true }
  vm_name                  = "vm${var.root_id}${each.value["vm_descriptor"]}${var.primary_short}${each.value["vm_number"]}"
  sku = each.value["sku"]
  location                 = var.primary_long
  resource_group_name      = "rg-${var.root_id}-${local.environment}-comp-${var.primary_short}-001"
  des_name =    "des-${var.root_id}-${local.environment}-${var.primary_short}-001"
  des_rg = "rg-${var.root_id}-${local.environment}-mgmt-${var.primary_short}-001"
  root_id                  = var.root_id
  private_ip_address       = each.value["ip_address_primary"]
  subnetname               = "snet-${local.environment}-virtualmachines-${var.primary_short}-001"
  virtual_network_name     = "vnet-${var.root_id}-${local.environment}-services-spoke-${var.primary_short}-001"
  snet_resource_group_name = "rg-${var.root_id}-${local.environment}-spoke-${var.primary_short}-001"
  server_os             = each.value["server_os"]
  bastion_ip            = local.bastion_primary
  tags                     = merge(var.management_resources_tags, { AZUpdate = each.value["vmupdate"], Role = each.value["role"], Environment = local.environment, Application = each.value["Application"], DR = each.value["DR"], AZBackup = each.value["Backup"]})
  depends_on = [module.subnet_creation]
  data_disks = each.value["data_disks"]

}
*/