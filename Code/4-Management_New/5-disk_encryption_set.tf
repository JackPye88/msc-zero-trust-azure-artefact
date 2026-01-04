module "disk_encryption_primary" {
  for_each = { for key, value in local.disk_encryption_set : key => value if value.deploy_primary == true }
  source   = "../../Modules/des"
  #This below source shows how it can be used with a DevOps Repo.
  #source = "git::https://<ORG_NAME>@dev.azure.com/<ORG_NAME>/<DEVOPS_PROJECT_NAME>/_git/adorepo-<DEVOPS_PROJECT_NAME>-terrafrom-modules-001//des"


  # Pass required variables as inputs
  root_id        = var.root_id
  environment    = local.environment
  location_short = var.primary_short
  location_long  = var.primary_long
  tags           = var.management_resources_tags
  key_vault_id   = module.create_kv["1-primary"].key_vault_id
  depends_on     = [null_resource.delay_execution_kv] # Ensures execution order


}

module "disk_encryption_secondary" {
  for_each = { for key, value in local.disk_encryption_set : key => value if value.deploy_secondary == true }

  source = "../../Modules/des"
  #This below source shows how it can be used with a DevOps Repo.
  #source = "git::https://<ORG_NAME>@dev.azure.com/<ORG_NAME>/<DEVOPS_PROJECT_NAME>/_git/adorepo-<DEVOPS_PROJECT_NAME>-terrafrom-modules-001//des"

  # Pass required variables as inputs
  root_id        = var.root_id
  environment    = local.environment
  location_short = var.secondary_short
  location_long  = var.secondary_long
  tags           = var.management_resources_tags
  key_vault_id   = module.create_kv["1-secondary"].key_vault_id
  depends_on     = [null_resource.delay_execution_kv] # Ensures execution order


}