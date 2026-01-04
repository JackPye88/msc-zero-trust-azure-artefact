module "deploy_vm" {
  source = "../../Modules/Virtual_Machine"
  providers = {
    azurerm.main         = azurerm
    azurerm.connectivity = azurerm.connectivity
  }

  # Deploy both primary and secondary dynamically
  for_each = merge(
    { for key, value in local.virtual_machines : "${key}-primary" => merge(value, { location = "primary" }) if value.deploy_primary == true },
    { for key, value in local.virtual_machines : "${key}-secondary" => merge(value, { location = "secondary" }) if value.deploy_secondary == true }
  )

  vm_name                  = "vm${var.root_id}${each.value["vm_descriptor"]}${each.value.location == "primary" ? var.primary_short : var.secondary_short}${each.value["vm_number"]}"
  sku                      = each.value["sku"]
  location                 = each.value.location == "primary" ? var.primary_long : var.secondary_long
  resource_group_name      = "rg-${var.root_id}-${var.environment}-comp-${each.value.location == "primary" ? var.primary_short : var.secondary_short}-001"
  des_name                 = "des-${var.root_id}-${var.environment}-${each.value.location == "primary" ? var.primary_short : var.secondary_short}-001"
  des_rg                   = "rg-${var.root_id}-${var.environment}-mgmt-${each.value.location == "primary" ? var.primary_short : var.secondary_short}-001"
  des_id                   = each.value.location == "primary" ? module.disk_encryption_primary.Base.des_id : module.disk_encryption_secondary.Base.des_id
  root_id                  = var.root_id
  private_ip_address       = each.value.location == "primary" ? each.value["ip_address_primary"] : each.value["ip_address_secondary"]
  subnetname               = each.value.location == "primary" ? module.subnet_creation["pe_subnet-primary"].subnet_name : module.subnet_creation["pe_subnet-secondary"].subnet_name
  subnet_id                = each.value.location == "primary" ? module.subnet_creation["vm_subnet-primary"].subnet_id : module.subnet_creation["vm_subnet-secondary"].subnet_id
  virtual_network_name     = "vnet-${var.root_id}-${var.environment}-services-spoke-${each.value.location == "primary" ? var.primary_short : var.secondary_short}-001"
  snet_resource_group_name = "rg-${var.root_id}-${var.environment}-spoke-${each.value.location == "primary" ? var.primary_short : var.secondary_short}-001"
  server_os                = each.value["server_os"]
  enable_aad_join          = each.value["enable_aad_join"]
  bastion_ip               = each.value.location == "primary" ? var.bastion_primary : var.bastion_secondary

  tags = merge(
    var.management_resources_tags,
    { AZUpdate = each.value["vmupdate"], role = each.value["role"], application = each.value["Application"], DR = each.value["DR"], AZBackup = each.value["Backup"] }
  )

  data_disks = each.value["data_disks"]
}
