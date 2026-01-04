data "azurerm_private_dns_zone" "appsvc" {
  provider            = azurerm.connectivity
  name                = "privatelink.azurewebsites.net"
  resource_group_name = "rg-jp-con-dns-uks-001"
}
resource "azurerm_service_plan" "plansec" {
  name                = "asp-jp-juice-zerotrust-uks-002"
  location            = var.primary_long
  resource_group_name = "rg-jp-zerotrust-secure-uks-001"

  os_type  = "Linux"
  sku_name = "B1" # recommended; change if you like (P0v3/P1v2/etc)

  tags = merge(var.management_resources_tags, {
    creationdate = formatdate("DD-MM-YYYY", timestamp())
    role         = "App Service Plan"
  })

  lifecycle {
    ignore_changes = [tags["creationdate"]]
  }
}


resource "azurerm_linux_web_app" "appsec" {
  name                = "app-jp-juice-zerotrust-uks-002"
  location            = var.primary_long
  resource_group_name = "rg-jp-zerotrust-secure-uks-001"
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

  public_network_access_enabled = false

  tags = merge(var.management_resources_tags, {
    creationdate = formatdate("DD-MM-YYYY", timestamp())
    role         = "App Service (Container)"
  })

  lifecycle {
    ignore_changes = [tags["creationdate"]]
  }
}


resource "azurerm_private_endpoint" "appsec" {
  name                = "pe-app-jp-juice-zerotrust-uks-002"
  location            = var.primary_long
  resource_group_name = "rg-jp-zerotrust-secure-uks-001"
  subnet_id           = module.subnet_creation["pe_subnet-primary"].subnet_id

  private_service_connection {
    name                           = "psc-app-jp-juice-zerotrust-uks-002"
    private_connection_resource_id = azurerm_linux_web_app.appsec.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "pdzg-appsvc"
    private_dns_zone_ids = [data.azurerm_private_dns_zone.appsvc.id]
  }

  tags = merge(var.management_resources_tags, {
    creationdate = formatdate("DD-MM-YYYY", timestamp())
    role         = "Private Endpoint"
  })

  lifecycle {
    ignore_changes = [tags["creationdate"]]
  }
}

resource "azurerm_public_ip" "appgw" {
  name                = "pip-appgw-waf-uks-001"
  location            = var.primary_long
  resource_group_name = "rg-jp-zerotrust-secure-uks-001"
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = merge(var.management_resources_tags,
    { "creationdate" = formatdate("DD-MM-YYYY", timestamp()),
      "role"         = "Container App Public IP"
  })
  lifecycle {
    ignore_changes = [tags["creationdate"]]
  }
}

resource "azurerm_network_security_rule" "agw_v2_inbound_ephemeral" {
  name                        = "Allow-AppGwV2-Ephemeral-Inbound"
  priority                    = 325
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["65200-65535"]
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
  resource_group_name         = "rg-jp-zerotrust-spoke-uks-001"
  network_security_group_name = "nsg-snet-zerotrust-agw-uks-001"
}

resource "azurerm_application_gateway" "waf" {
  name                = "agw-jp-waf-uks-001"
  location            = var.primary_long
  resource_group_name = "rg-jp-zerotrust-secure-uks-001"

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "gwipcfg"
    subnet_id = module.subnet_creation["agw_subnet-primary"].subnet_id
  }

  frontend_port {
    name = "feport-http"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "feip"
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  # Backend points to the internal ACA FQDN
  backend_address_pool {
    name         = "be-aca"
    fqdns        = ["app-jp-juice-zerotrust-uks-002.azurewebsites.net"]
    ip_addresses = ["172.16.64.126"]
  }

  backend_http_settings {
    name                                = "be-https"
    protocol                            = "Https"
    port                                = 443
    cookie_based_affinity               = "Disabled"
    pick_host_name_from_backend_address = false
    request_timeout                     = 60
    host_name                           = "app-jp-juice-zerotrust-uks-002.azurewebsites.net"
  }

  http_listener {
    name                           = "listener-http"
    frontend_ip_configuration_name = "feip"
    frontend_port_name             = "feport-http"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "rule1"
    rule_type                  = "Basic"
    http_listener_name         = "listener-http"
    backend_address_pool_name  = "be-aca"
    backend_http_settings_name = "be-https"
    priority                   = 10
  }

  firewall_policy_id = azurerm_web_application_firewall_policy.waf_policy.id

  tags = merge(var.management_resources_tags,
    { "creationdate" = formatdate("DD-MM-YYYY", timestamp()),
      "role"         = "Container App AGW"
  })
  lifecycle {
    ignore_changes = [tags["creationdate"]]
  }
}


resource "azurerm_web_application_firewall_policy" "waf_policy" {
  name                = "wafpol-jp-waf-uks-001"
  location            = var.primary_long
  resource_group_name = "rg-jp-zerotrust-secure-uks-001"

  policy_settings {
    enabled                     = true
    mode                        = "Prevention"
    request_body_check          = true
    file_upload_limit_in_mb     = 100
    max_request_body_size_in_kb = 128
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }

  tags = merge(var.management_resources_tags, {
    creationdate = formatdate("DD-MM-YYYY", timestamp())
    role         = "AppGW WAF Policy"
  })

  lifecycle {
    ignore_changes = [tags["creationdate"]]
  }
}
