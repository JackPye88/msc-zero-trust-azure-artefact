
resource "azurerm_linux_web_app" "appinsec" {
  name                = "app-jp-juice-insecure-uks-001"
  location            = var.primary_long
  resource_group_name = "rg-jp-zerotrust-insecure-uks-001"
  service_plan_id     = azurerm_service_plan.plansec.id

  https_only = false

  app_settings = {
    WEBSITES_PORT = "3000"
  }

  site_config {
    always_on = true

    application_stack {
      docker_image_name   = "bkimminich/juice-shop:latest"
      docker_registry_url = "https://index.docker.io"
    }
  }

  public_network_access_enabled = true

  tags = merge(var.management_resources_tags, {
    creationdate = formatdate("DD-MM-YYYY", timestamp())
    role         = "App Service (Container)"
  })

  lifecycle {
    ignore_changes = [tags["creationdate"]]
  }
}
