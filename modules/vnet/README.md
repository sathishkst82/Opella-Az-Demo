# VNET Module

Reusable Azure Virtual Network module for segmented enterprise landing zones.

Design decisions:

- `for_each` creates deterministic subnet, NSG, route table, and private DNS link resources keyed by stable names.
- Dynamic delegation blocks keep the module generic for App Service, AKS, Container Apps, or database delegations.
- Optional DDoS, NSG, route table, and private DNS resources allow the same module to serve DEV through PROD without forks.
- `prevent_destroy` protects the VNET from accidental deletion because networks carry many downstream dependencies.
- `create_before_destroy` on replaceable resources reduces outage risk when names or route definitions change.
- `ignore_changes` for the operational tag `LastPatchedBy` avoids noisy plans caused by external patching automation.

<!-- BEGIN_TF_DOCS -->
Run `terraform-docs` to refresh generated input and output tables.
<!-- END_TF_DOCS -->
