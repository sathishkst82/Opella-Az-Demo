output "policy_definition_ids" {
  description = "Custom policy definition IDs."
  value = {
    require_tags    = azurerm_policy_definition.require_tags.id
    allowed_regions = azurerm_policy_definition.allowed_regions.id
    deny_public_ip  = azurerm_policy_definition.deny_public_ip.id
  }
}

output "initiative_id" {
  description = "Policy initiative ID."
  value       = azurerm_policy_set_definition.baseline.id
}

output "assignment_id" {
  description = "Policy assignment ID."
  value       = azurerm_resource_group_policy_assignment.baseline.id
}
