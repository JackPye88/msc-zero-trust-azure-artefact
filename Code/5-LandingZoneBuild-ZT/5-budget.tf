

resource "azurerm_consumption_budget_subscription" "Subscription_budget" {

  name            = "budget-${var.environment}-subscription"
  subscription_id = "/subscriptions/${var.subscription_id}"
  amount          = var.budget_limit # Budget limit in your Azure subscription's currency
  time_grain      = "Monthly"        # Options: Daily, Monthly, Quarterly, Annually

  time_period {
    start_date = formatdate("YYYY-MM-01'T'hh:mm:ssZ", timestamp())
    #end_date   = "2024-12-31T23:59:59Z"
  }


  notification {
    enabled        = true
    operator       = "GreaterThan"
    threshold      = 90 # Trigger at 80% of the budget
    contact_emails = ["jack.pye@bob.com"]
    contact_roles  = ["Owner"]
  }

  notification {
    enabled        = true
    operator       = "GreaterThan"
    threshold      = 100 # Trigger at 90% of the budget
    contact_emails = ["jack.pye@bob.com"]
    contact_roles  = ["Owner"]
  }

  notification {
    enabled        = true
    operator       = "GreaterThan"
    threshold      = 110 # Trigger at 100% of the budget
    contact_emails = ["jack.pye@bob.com"]
    contact_roles  = ["Owner"]
  }
  lifecycle {
    ignore_changes = [
      time_period
    ]
  }
}
