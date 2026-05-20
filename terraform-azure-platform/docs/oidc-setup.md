# OIDC Setup Guide

This platform uses GitHub OIDC federation only. No Azure client secrets are stored in GitHub.

Create an app registration:

```bash
az ad app create --display-name app-github-opella-terraform
APP_ID=$(az ad app list --display-name app-github-opella-terraform --query "[0].appId" -o tsv)
az ad sp create --id "$APP_ID"
```

Create federated credentials for each GitHub Environment:

```bash
az ad app federated-credential create --id "$APP_ID" --parameters '{
  "name": "github-env-dev",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:<ORG>/<REPO>:environment:DEV",
  "description": "GitHub OIDC for DEV Terraform",
  "audiences": ["api://AzureADTokenExchange"]
}'
```

Repeat with `UAT` and `PROD` subjects.

Assign Azure RBAC:

```bash
az role assignment create --assignee "$APP_ID" --role Contributor --scope /subscriptions/<SUBSCRIPTION_ID>
az role assignment create --assignee "$APP_ID" --role "User Access Administrator" --scope /subscriptions/<SUBSCRIPTION_ID>
az role assignment create --assignee "$APP_ID" --role "Storage Blob Data Contributor" --scope /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<STATE_RG>/providers/Microsoft.Storage/storageAccounts/<STATE_ACCOUNT>
```

Security benefits:

- Short-lived tokens replace static client secrets.
- Trust is constrained to repository, branch, and GitHub Environment claims.
- PROD can require GitHub reviewer approval before the OIDC token is minted for apply.
- Azure sign-in logs provide auditability for every workflow run.
