# GitHub Environment Configuration Guide

Create these environments exactly: `DEV`, `UAT`, `PROD`.

Recommended controls:

| Environment | Reviewers | Branch policy | Notes |
| --- | --- | --- | --- |
| DEV | Optional | Feature and main branches | Fast feedback and module validation. |
| UAT | Platform team | Release branches and main | Pre-production validation. |
| PROD | Required | Protected main branch only | Manual approval is mandatory. |

Use environment-level variables and secrets so the same reusable workflow deploys all stages without hardcoding tenant, subscription, or backend values.

Required secrets include the Terraform backend values, Wiz service account values, optional `EXTRA_ARGS`, and `WINDOWS_ADMIN_PASSWORD` for Windows VM provisioning.

The dispatch workflow accepts optional operational inputs for `terraform force-unlock`, `terraform import`, and `terraform state rm`. These are intentionally explicit and audited through workflow run history.
