# Environment Setup Guide

Create GitHub Environments named `DEV`, `UAT`, and `PROD`. Configure required reviewers on `PROD` so `terraform-apply.yml` and `terraform-destroy-apply.yml` pause for manual approval.

Environment variables:

| Name | Purpose |
| --- | --- |
| `AZURE_CLIENT_ID` | App registration client ID used by GitHub OIDC federation. |
| `AZURE_TENANT_ID` | Microsoft Entra tenant ID. |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription targeted by the environment. |

Environment secrets:

| Name | Purpose |
| --- | --- |
| `TF_BACKEND_RESOURCE_GROUP` | Resource group containing the remote state storage account. |
| `TF_BACKEND_STORAGE_ACCOUNT` | Remote state storage account name. |
| `TF_BACKEND_CONTAINER` | Remote state blob container name. |
| `TF_BACKEND_KEY` | Environment state file key, for example `opella/dev.tfstate`. |
| `WIZ_CLIENT_ID` | Wiz service account client ID for IaC scanning. |
| `WIZ_CLIENT_SECRET` | Wiz service account secret. |
| `WINDOWS_ADMIN_PASSWORD` | Sensitive Windows VM local administrator password injected as `TF_VAR_admin_password`. |
| `EXTRA_ARGS` | Optional additional Terraform CLI args used only when dispatch input enables it. |

Remote backend bootstrap example:

```bash
terraform init \
  -backend-config="resource_group_name=$TF_BACKEND_RESOURCE_GROUP" \
  -backend-config="storage_account_name=$TF_BACKEND_STORAGE_ACCOUNT" \
  -backend-config="container_name=$TF_BACKEND_CONTAINER" \
  -backend-config="key=$TF_BACKEND_KEY"
```

Recommended state keys:

| Environment | Backend key |
| --- | --- |
| DEV | `opella/dev.tfstate` |
| UAT | `opella/uat.tfstate` |
| PROD | `opella/prod.tfstate` |
