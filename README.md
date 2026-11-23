# Cross-account CI role module

CI should not hold long-lived access keys for other accounts. This module creates
one IAM role in a workload account that a single CI role from the shared-services
account can assume. Access needs an external ID, lasts one hour, and is limited to
the actions and resources you list.

```mermaid
flowchart LR
  A[CI role<br/>shared-services account] -->|AssumeRole + external ID| B[Workload role<br/>workload account]
  B --> C[Allowed actions only]
```

## Usage

```hcl
module "ci_role" {
  source = "github.com/zeinhaidara/04-terraform-cross-account-ci-role"

  ci_role_arn = "arn:aws:iam::123456789012:role/ci-runner"
  external_id = var.external_id # keep it in a secret store

  allowed_actions = ["s3:GetObject", "s3:ListBucket"]
  resource_arns = [
    "arn:aws:s3:::example-artifacts",
    "arn:aws:s3:::example-artifacts/*",
  ]

  tags = { team = "platform" }
}
```

Outputs: `role_arn`, `role_name`. No policy is attached until `resource_arns` is set.

## Known limitations

- No permission boundary and no SCP check.
- The external ID is only as secret as its storage.
- No MFA requirement, because CI cannot use MFA.
- Partial wildcards such as `s3:Get*` are allowed. Only `*` and `service:*` are blocked.

## Checks

```
terraform fmt -check
terraform init -backend=false
terraform validate
terraform test
```

`terraform test` plans against a mocked AWS provider, so it needs no
credentials. Four runs check that the trust policy names the exact CI role,
that the external ID is required, that wildcard actions are rejected, and
that the session lasts one hour. Nothing has been applied to a real AWS
account.
