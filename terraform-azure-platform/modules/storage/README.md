# Storage Module

Reusable storage module with HTTPS-only access, TLS 1.2, blob versioning, soft delete, lifecycle management, private containers, firewall rules, and optional Private Endpoint integration.

The storage account has `prevent_destroy` because accidental deletion destroys blob data and Terraform state-like artifacts. Public blob access is disabled at account level and every generated container defaults to private.

<!-- BEGIN_TF_DOCS -->
Run `terraform-docs` to refresh generated input and output tables.
<!-- END_TF_DOCS -->
