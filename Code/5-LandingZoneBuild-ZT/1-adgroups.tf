resource "azuread_group" "aad_groups" {
  for_each = var.aad_groups

  display_name     = "SG_${each.value.prefix}_${var.sg_name_environment}_${each.value.name_suffix}"
  description      = "${each.value.description} (${var.sg_name_environment})"
  mail_enabled     = false
  security_enabled = true
}
resource "azurerm_role_assignment" "mgmt_group_roles" {
  for_each = {
    for assignment in flatten([
      for group_key, group in var.aad_groups : [
        for idx, role in lookup(group, "role_assignments", []) :
        role.scope == "mgmt_group"
        ? merge(role, { group_key = group_key, idx = idx })
        : null
      ]
    ]) :
    "${assignment.group_key}-${assignment.idx}" => assignment
    if assignment != null
  }

  principal_id         = azuread_group.aad_groups[each.value.group_key].object_id
  role_definition_name = each.value.role_name
  scope                = data.azurerm_management_group.mg.id
  provider             = azurerm
}


data "azurerm_management_group" "mg" {
  name = var.management_group_name
}
data "azurerm_resource_group" "dns" {
  provider = azurerm.connectivity
  name     = var.dns_resource_group_name
}
