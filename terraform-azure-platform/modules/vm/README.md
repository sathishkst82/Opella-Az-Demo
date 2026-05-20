# VM Module

Reusable Windows VM module with multiple instance support, managed identity, password authentication, boot diagnostics, optional public IPs, and optional data disks.

Public IPs are disabled by default to align with private-first enterprise network patterns. VMs use `prevent_destroy` because compute instances may host stateful operational tools during assessment demos; production immutable workloads can relax this in a fork if replacement is fully automated.

<!-- BEGIN_TF_DOCS -->
Run `terraform-docs` to refresh generated input and output tables.
<!-- END_TF_DOCS -->
