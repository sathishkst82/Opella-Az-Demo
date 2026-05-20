resource "azurerm_policy_set_definition" "baseline" {
  name         = "Opella-Governance-Baseline"
  policy_type  = "Custom"
  display_name = "Opella Governance Baseline"

  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/1e30110a-5ceb-460c-a204-c1c3969c6d62"
    reference_id         = "require-tags"
  }
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"
    reference_id         = "allowed-locations"
  }
  policy_definition_reference {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/6fac406b-40ca-413b-bf8e-0bf964659c25"
    reference_id         = "deny-public-ip"
  }
}
resource "azurerm_resource_group_policy_assignment" "this" {
  name                 = "opella-governance-assignment"
  resource_group_id    = var.resource_group_id
  policy_definition_id = azurerm_policy_set_definition.baseline.id
  location             = var.location
}
