# Assessment Guide

This repository demonstrates a reusable Terraform module pattern and a GitHub Actions release workflow for deploying Azure infrastructure across multiple environments. The main implementation lives under `terraform-azure-platform/`.

## What This Repository Builds

The platform deploys an Azure environment with:

- A Resource Group per environment.
- A reusable Virtual Network module with subnets, NSGs, route tables, optional DDoS protection, and private DNS links.
- A Windows VM for operational access or development tooling.
- A Storage Account with containers, lifecycle rules, network restrictions, and an optional Private Endpoint.
- A Private DNS zone for storage private endpoint resolution.
- A Log Analytics workspace and diagnostic setting.
- Azure Policy governance for required tags, allowed regions, and public IP control.
- GitHub Actions workflows for validate, plan, apply, destroy-plan, and destroy-apply.

## Requirement Coverage

### 1. Reusable VNET Module

The reusable VNET module is located at:

```text
terraform-azure-platform/modules/vnet
```

It accepts configurable inputs for:

- Resource group name
- Azure region
- VNET name
- Address space
- Subnet map
- DNS servers
- Tags
- Default service endpoints
- Subnet delegations
- NSG rules
- Route tables
- Private DNS links
- Optional DDoS protection

The module creates:

- `azurerm_virtual_network`
- `azurerm_subnet`
- `azurerm_network_security_group`
- `azurerm_network_security_rule`
- `azurerm_subnet_network_security_group_association`
- `azurerm_route_table`
- `azurerm_subnet_route_table_association`
- `azurerm_private_dns_zone_virtual_network_link`
- Optional `azurerm_network_ddos_protection_plan`

Security-oriented design choices:

- NSGs are enabled by default for subnets unless explicitly disabled.
- Private endpoint subnet support is included.
- Route tables can be attached per subnet.
- DDoS protection can be enabled when required.
- `prevent_destroy` protects the VNET from accidental deletion.
- Tags are normalized and applied to resources created by the module.

Useful outputs:

- `vnet_id`: used by downstream modules, peering, diagnostics, or policy assignments.
- `vnet_name`: useful for release summaries and operational checks.
- `resource_group_name`: useful when consuming outputs from automation.
- `subnet_ids`: required by VM, private endpoint, AKS, App Service, and database modules.
- `subnet_names`: useful for documentation, summaries, and validation.

### 2. Infrastructure Setup

Environment folders are located at:

```text
terraform-azure-platform/environments/dev
terraform-azure-platform/environments/uat
terraform-azure-platform/environments/prod
```

The dev environment is implemented in `eastus` and is designed so UAT and PROD can follow the same pattern with different variables and CIDR ranges.

The environment deploys:

- Resource group
- VNET module
- Management, application, data, private endpoint, and reserved subnets
- NSG rule allowing RDP only from private address space
- Route table for egress
- Windows VM
- Storage account
- Blob containers
- Storage private endpoint
- Private DNS zone and VNET link
- Log Analytics workspace
- Storage diagnostic settings
- Governance policy assignment

### 3. Resource Groups vs Subscriptions

This design uses one Resource Group per environment in the same subscription by default. That is a good fit for a demo or a smaller platform because it keeps setup simple while still giving clear boundaries for naming, tagging, access control, cost tracking, and lifecycle operations.

For larger enterprise use, separate subscriptions can be introduced per environment or per landing zone. Separate subscriptions provide stronger isolation, clearer budget controls, policy boundaries, and reduced blast radius. The module and environment layout can scale to that model because subscription-specific values are supplied through GitHub variables and Terraform provider configuration.

### 4. Naming And Tagging

Naming is centralized in environment `locals`, for example:

```hcl
locals {
  name_prefix = "${var.project}-${var.environment}-${var.location}"

  names = {
    resource_group = "rg-${local.name_prefix}"
    vnet           = "vnet-${local.name_prefix}"
    vm             = "vm-${local.name_prefix}-001"
    storage        = substr("st${local.compact}001", 0, 24)
  }
}
```

Common tags are also centralized:

```hcl
common_tags = {
  Environment = upper(var.environment)
  Project     = var.project
  ManagedBy   = "Terraform"
  Owner       = var.owner
  CostCenter  = var.cost_center
  Region      = var.location
  Application = var.application
}
```

These tags help with:

- Ownership
- Cost allocation
- Chargeback
- Incident triage
- Policy compliance
- Environment tracking

Tag enforcement is represented in:

```text
terraform-azure-platform/modules/governance
```

The governance module defines and assigns policies for required tags, allowed regions, and public IP control.

## How To Use The VNET Module

Example:

```hcl
module "network" {
  source = "../../modules/vnet"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  vnet_name           = "vnet-opella-dev-eastus"
  address_space       = ["10.10.0.0/16"]
  tags                = local.common_tags

  subnets = {
    management = {
      name             = "management-subnet"
      address_prefixes = ["10.10.0.0/24"]
      nsg_rules        = ["allow-rdp-private"]
      route_table      = "rt-opella-dev-eastus-egress"
    }
    private_endpoint = {
      name                                          = "private-endpoint-subnet"
      address_prefixes                              = ["10.10.30.0/24"]
      private_endpoint_network_policies_enabled     = false
      private_link_service_network_policies_enabled = false
      create_nsg                                    = false
    }
  }

  nsg_rules = {
    management = [{
      name                       = "allow-rdp-private"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "3389"
      source_address_prefix      = "10.0.0.0/8"
      destination_address_prefix = "*"
    }]
  }
}
```

## GitHub Actions Release Lifecycle

The dispatch workflow is:

```text
terraform-azure-platform/.github/workflows/iac-dispatch.yml
```

Supported actions:

- `validate`: runs formatting, Terraform init, validation, docs checks, and TFLint.
- `plan`: creates a Terraform plan and uploads it as an artifact.
- `plan-apply`: runs a plan and then applies it.
- `destroy-plan`: creates a destroy plan.
- `destroy-apply`: creates and applies a destroy plan.

Recommended release flow:

1. Run `validate`.
2. Run `plan` and review the proposed changes.
3. Run `plan-apply` only after the plan is acceptable.
4. Use `destroy-plan` and `destroy-apply` separately to reduce accidental deletion risk.

The workflows use GitHub OIDC with Azure, so no long-lived Azure client secret is required.

Required GitHub variables:

```text
AZURE_CLIENT_ID
AZURE_TENANT_ID
AZURE_SUBSCRIPTION_ID
```

Required GitHub secrets:

```text
TF_BACKEND_RESOURCE_GROUP
TF_BACKEND_STORAGE_ACCOUNT
TF_BACKEND_CONTAINER
TF_BACKEND_KEY
WINDOWS_ADMIN_PASSWORD
```

Optional GitHub variable for Wiz:

```text
ENABLE_WIZ_SCAN=true
```

Optional GitHub secrets for Wiz:

```text
WIZ_CLIENT_ID
WIZ_CLIENT_SECRET
```

Wiz is included as an optional security scan step. It is skipped unless `ENABLE_WIZ_SCAN` is set to `true` and credentials are provided.

## Documentation Automation

The repository is prepared for documentation automation with `terraform-docs`.

The validate workflow runs documentation generation checks for:

```text
modules/vnet
modules/vm
modules/storage
modules/governance
```

To generate module documentation locally:

```bash
terraform-docs markdown table terraform-azure-platform/modules/vnet
terraform-docs markdown table terraform-azure-platform/modules/vm
terraform-docs markdown table terraform-azure-platform/modules/storage
terraform-docs markdown table terraform-azure-platform/modules/governance
```

## Testing

The VNET module has a test scaffold under:

```text
terraform-azure-platform/tests
terraform-azure-platform/tests/fixtures/vnet
```

This demonstrates how the module can be tested independently using fixture-based Terraform tests or Terratest-style Go tests.

The main checks used in the pipeline are:

- `terraform fmt`
- `terraform init`
- `terraform validate`
- `tflint`
- Optional Wiz IaC scan

## How To Present This In The Assessment

Key points to explain:

- The VNET module is reusable because it takes maps and objects rather than hardcoded subnet resources.
- Environments are separated by folder and can scale from Resource Group isolation to subscription isolation.
- Names and tags are generated from locals to avoid repetition.
- Security controls include NSGs, private endpoints, private DNS links, DDoS readiness, policy governance, and lifecycle protection.
- The pipeline separates validation, planning, applying, and destroying.
- Azure authentication uses OIDC instead of storing Azure client secrets in GitHub.
- Wiz is included as an optional enterprise security control behind a feature flag.
