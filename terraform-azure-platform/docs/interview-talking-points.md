# Interview Talking Points

- The repository separates environment composition from reusable modules, which keeps module contracts stable and environment policy explicit.
- The VNET module supports dynamic delegations, NSGs, route tables, private DNS links, service endpoints, and optional DDoS, so it can serve simple and advanced topologies.
- Naming and tagging are centralized in environment locals. This improves drift detection, FinOps reporting, ownership, and Azure Policy compliance.
- Terraform backend configuration is injected at runtime from GitHub Environment secrets, so state location is not hardcoded in source control.
- GitHub Actions uses reusable `workflow_call` workflows and a single dispatch entrypoint. This models enterprise orchestration while keeping implementation readable.
- Authentication uses GitHub OIDC federation. This removes client secret rotation risk and aligns Azure access with GitHub environment approvals.
- Governance is implemented as Azure Policy definitions grouped into an initiative and assigned per resource group. This is runtime enforcement, not just CI linting.
- Wiz scanning is placed before plan artifact upload to catch misconfigurations, public exposure, weak encryption, and policy violations early.
- PROD differs from lower environments through stricter policy enforcement, longer monitoring retention, ZRS storage, and DDoS enablement.
- Terratest validates module behavior and outputs, while `terraform validate`, TFLint, Wiz, and docs checks provide layered quality gates.
