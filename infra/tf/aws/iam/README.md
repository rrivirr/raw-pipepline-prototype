# iam

Submodule creating one IAM role plus the customer-managed S3 access policy
attached to it. Called by the root module in `../`; it takes no provider or
backend configuration of its own.

## Inputs

| Name | Type | Required | Description |
|---|---|---|---|
| `role_name` | `string` | yes | Role name; also names the managed policy. |
| `bucket_name` | `string` | yes | Bucket the policy targets — the `<my_bucket>` placeholder. |
| `trusted_principal_arns` | `list(string)` | yes | Principals allowed to assume the role. Must be non-empty. |
| `external_id` | `string` | no (`null`) | Requires a matching `sts:ExternalId` on assume-role. |

## Outputs

`role_arn`, `role_name`, `role_unique_id`, `policy_arn`, `policy_json`.

## Resources

| Address | Purpose |
|---|---|
| `aws_iam_role.bucket_access` | The role and its trust policy. |
| `aws_iam_policy.bucket_access` | The access policy from the spec. |
| `aws_iam_role_policy_attachment.bucket_access` | Binds the two. |

Both policies are built with `aws_iam_policy_document` data sources rather than
heredoc JSON, so action names and condition keys are checked against the
provider schema at plan time. `terraform output policy_json` renders the result
for comparison against the source document.

## Reuse

The role name is an input, so a second instantiation gives a second role — for
example a read-only consumer alongside the writer:

```hcl
module "iam_reader" {
  source = "./iam"

  role_name              = "rriv-sensor-data-reader"
  bucket_name            = var.bucket_name
  trusted_principal_arns = var.reader_principal_arns
}
```

The policy document is fixed at the one in the spec, so a reader instantiation
would need the action list parameterised first.
