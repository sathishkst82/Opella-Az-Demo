locals {
  require_tags_policy_rule = {
    if = {
      anyOf = [
        for tag in var.required_tags : {
          field  = "tags['${tag}']"
          exists = "false"
        }
      ]
    }
    then = {
      effect = "deny"
    }
  }
}

resource "azurerm_policy_definition" "require_tags" {
  name         = "opella-require-tags"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Opella - Require mandatory tags"
  description  = "Denies resources missing mandatory tags."
  policy_rule  = jsonencode(local.require_tags_policy_rule)
}

resource "azurerm_policy_set_definition" "baseline" {
  name         = "Opella-Governance-Baseline"
  policy_type  = "Custom"
  display_name = "Opella Governance Baseline"

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.require_tags.id
    reference_id         = "require-tags"
  }
}
resource "azurerm_resource_group_policy_assignment" "this" {
  name                 = "opella-governance-assignment"
  resource_group_id    = var.resource_group_id
  policy_definition_id = azurerm_policy_set_definition.baseline.id
  location             = var.location
}
