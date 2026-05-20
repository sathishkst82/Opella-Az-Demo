# Opella Azure Terraform Demo

This repository contains an Azure Infrastructure-as-Code demo built with Terraform and GitHub Actions.

The maintained implementation lives in:

```text
terraform-azure-platform/
```

Start here:

- [Platform README](terraform-azure-platform/README.md)
- [Assessment Guide](terraform-azure-platform/docs/assessment-guide.md)
- [VNET Module](terraform-azure-platform/modules/vnet)
- [GitHub Actions Workflows](.github/workflows)

GitHub Actions workflows must remain in the repository root under `.github/workflows/` so GitHub can discover them. Those workflows deploy the Terraform code from `terraform-azure-platform/`.
