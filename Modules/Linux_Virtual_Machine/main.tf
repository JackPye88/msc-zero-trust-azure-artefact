data "azurerm_subnet" "snet_lookup" {
  provider             = azurerm.main
  name                 = var.subnetname
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.snet_resource_group_name
}
data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {
}
data "azurerm_disk_encryption_set" "lookup" {
  name                = var.des_name
  resource_group_name = var.des_rg
}

resource "azurerm_managed_disk" "data_disks" {
  for_each = { for index, disk in var.data_disks : index => disk }

  name                 = "${var.vm_name}-${each.value.name}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = each.value.storage_account_type
  disk_size_gb         = each.value.size
  create_option        = "Empty"
  tags = merge(
    var.tags,
    {
      "creationdate" = formatdate("DD-MM-YYYY", timestamp())
      "Role"         = join(" ", ["Managed Disk For", var.vm_name])
    }
  )
}
resource "azurerm_network_interface" "create_nic" {
  provider            = azurerm.main
  name                = "nic-${var.vm_name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "nic-${var.vm_name}"
    subnet_id                     = data.azurerm_subnet.snet_lookup.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.private_ip_address
  }
  tags = merge(
    var.tags,
    {
      "creationdate" = formatdate("DD-MM-YYYY", timestamp())
      "Role"         = join(" ", ["NIC For", var.vm_name])
    }
  )
  lifecycle {
    ignore_changes = [
      ip_configuration[0].subnet_id
    ]
  }
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "main" {
  name                              = var.vm_name
  provider                          = azurerm.main
  admin_username                    = "adminuser"
  admin_password                    = "PASSWORD"
  location                          = var.location
  resource_group_name               = var.resource_group_name
  network_interface_ids             = [azurerm_network_interface.create_nic.id]
  size                              = var.sku
  vtpm_enabled                      = "false"
  secure_boot_enabled               = "false"
  encryption_at_host_enabled        = "true"
  vm_agent_platform_updates_enabled = true
  disable_password_authentication   = false

  identity {
    type = "SystemAssigned"
  }
  os_disk {
    name                   = "${var.vm_name}-OsDisk"
    caching                = "ReadWrite"
    storage_account_type   = "Premium_LRS"
    disk_encryption_set_id = data.azurerm_disk_encryption_set.lookup.id
  }
  provision_vm_agent = true
  # Attach managed disk IDs

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = merge(
    var.tags,
    {
      "creationdate" = formatdate("DD-MM-YYYY", timestamp())
    }
  )
  lifecycle {
    ignore_changes = [
      os_disk[0].disk_encryption_set_id
    ]
  }

}

resource "azurerm_virtual_machine_data_disk_attachment" "data_disk_attachment" {
  for_each           = azurerm_managed_disk.data_disks
  managed_disk_id    = each.value.id
  virtual_machine_id = azurerm_linux_virtual_machine.main.id
  lun                = each.key # Use each.key as the numeric LUN
  caching            = "ReadWrite"
}

resource "azapi_resource" "policy" {
  name                      = "${resource.azurerm_linux_virtual_machine.main.name}-edge-just-in-time-policy"
  parent_id                 = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${resource.azurerm_linux_virtual_machine.main.resource_group_name}/providers/Microsoft.Security/locations/${resource.azurerm_linux_virtual_machine.main.location}"
  type                      = "Microsoft.Security/locations/jitNetworkAccessPolicies@2020-01-01"
  schema_validation_enabled = false

  body = jsonencode({
    kind = "Basic"
    properties = {
      virtualMachines = [
        {
          id = "/subscriptions/${data.azurerm_subscription.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Compute/virtualMachines/${var.vm_name}"
          ports = [
            {
              number                     = "22"
              protocol                   = "TCP"
              allowedSourceAddressPrefix = var.bastion_ip
              maxRequestAccessDuration   = "PT3H"
            }
          ]
        }
      ]
    }
  })
  lifecycle {
    ignore_changes = [
      # Specify attributes to ignore
      body,
      output,
      parent_id,
      location
    ]
  }

}