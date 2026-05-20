# Governance Module

Creates custom Azure Policy definitions, groups them into the `Opella-Governance-Baseline` initiative, and assigns the initiative to an environment resource group.

Governance as Code keeps policy controls peer-reviewed and versioned with infrastructure. OPA or Conftest can be added later as pre-deployment policy checks in CI, while Azure Policy remains the runtime enforcement plane.

<!-- BEGIN_TF_DOCS -->
Run `terraform-docs` to refresh generated input and output tables.
<!-- END_TF_DOCS -->
