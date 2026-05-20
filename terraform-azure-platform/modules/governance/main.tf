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

  allowed_regions_policy_rule = {
    if = {
      allOf = [
        {
          field = "location"
          notIn = "[parameters('allowedLocations')]"
        },
        {
          field     = "location"
          notEquals = "global"
        }
      ]
    }
    then = {
      effect = "deny"
    }
  }

  deny_public_ip_policy_rule = {
    if = {
      field  = "type"
      equals = "Microsoft.Network/publicIPAddresses"
    }
    then = {
      effect = "deny"
    }
  }
}

resource "azurerm_policy_definition" "require_tags" {
  name         = "${var.policy_name_prefix}-require-tags"
  display_name = "Opella - Require mandatory tags"
  policy_type  = "Custom"
  mode         = "Indexed"
  description  = "Denies resources missing mandatory enterprise tags."
  policy_rule  = jsonencode(local.require_tags_policy_rule)
}

resource "azurerm_policy_definition" "allowed_regions" {
  name         = "${var.policy_name_prefix}-allowed-regions"
  display_name = "Opella - Allowed Azure regions"
  policy_type  = "Custom"
  mode         = "Indexed"
  description  = "Denies resources outside approved Azure regions."
  policy_rule  = jsonencode(local.allowed_regions_policy_rule)

  parameters = jsonencode({
    allowedLocations = {
      type = "Array"
      metadata = {
        displayName = "Allowed locations"
      }
    }
  })
}

resource "azurerm_policy_definition" "deny_public_ip" {
  name         = "${var.policy_name_prefix}-deny-public-ip"
  display_name = "Opella - Deny Public IP"
  policy_type  = "Custom"
  mode         = "All"
  description  = "Denies creation of standalone public IP resources."
  policy_rule  = jsonencode(local.deny_public_ip_policy_rule)
}

resource "azurerm_policy_set_definition" "baseline" {
  name         = "${var.policy_name_prefix}-governance-baseline"
  display_name = var.initiative_name
  policy_type  = "Custom"
  description  = "Baseline initiative for tag, region, and public exposure controls."

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.require_tags.id
    reference_id         = "RequireTags"
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.allowed_regions.id
    reference_id         = "AllowedRegions"
    parameter_values = jsonencode({
      allowedLocations = {
        value = "[parameters('allowedLocations')]"
      }
    })
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.deny_public_ip.id
    reference_id         = "DenyPublicIP"
  }

  parameters = jsonencode({
    allowedLocations = {
      type = "Array"
      metadata = {
        displayName = "Allowed locations"
      }
    }
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_resource_group_policy_assignment" "baseline" {
  name                 = "${var.policy_name_prefix}-governance-baseline"
  resource_group_id    = var.assignment_scope
  policy_definition_id = azurerm_policy_set_definition.baseline.id
  display_name         = var.initiative_name
  enforce              = var.enforcement_mode == "Default"
  description          = "Assignment of the Opella baseline governance initiative."

  parameters = jsonencode({
    allowedLocations = {
      value = var.allowed_locations
    }
  })
}
