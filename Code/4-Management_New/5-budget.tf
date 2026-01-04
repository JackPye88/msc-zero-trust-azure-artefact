

resource "azurerm_consumption_budget_subscription" "Subscription_budget" {

  name            = "budget-${local.environment}-subscription"
  subscription_id = "/subscriptions/${local.subscription_id}"
  amount          = local.budget_limit # Budget limit in your Azure subscription's currency
  time_grain      = "Monthly"          # Options: Daily, Monthly, Quarterly, Annually

  time_period {
    start_date = formatdate("YYYY-MM-01'T'hh:mm:ssZ", timestamp())
    #end_date   = "2024-12-31T23:59:59Z"
  }


  # Loop through the notifications defined in locals
  dynamic "notification" {
    for_each = local.budget_notifications
    content {
      enabled        = notification.value.enabled
      operator       = notification.value.operator
      threshold      = notification.value.threshold
      contact_emails = notification.value.contact_emails
      contact_roles  = notification.value.contact_roles
    }
  }
  lifecycle {
    ignore_changes = [
      time_period
    ]
  }
}
