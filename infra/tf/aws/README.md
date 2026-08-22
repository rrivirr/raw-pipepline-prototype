# aws

Terraform configuration for the IAM role granting access to the
`rriv-sensor-data` table, per `../../prompts/generate-aws-terraform.md`.

File organisation mirrors `../tigercloud`: `versions.tf` holds the terraform
block and backend, `providers.tf` the provider, and `variables.tf` /
`main.tf` / `outputs.tf` the configuration. The role itself lives in the
`iam/` submodule.

```
aws/
├── versions.tf                 # required_version, providers, local backend
├── providers.tf                # aws provider
├── variables.tf
├── main.tf                     # calls module "iam"
├── outputs.tf
├── terraform.tfvars.example
├── .gitignore
└── iam/                        # submodule: role + policy + attachment
    ├── versions.tf
    ├── variables.tf
    ├── main.tf
    ├── outputs.tf
    └── README.md
```

## What it creates

| Resource | Name |
|---|---|
| `aws_iam_role` | `rriv-sensor-data-access` |
| `aws_iam_policy` | `rriv-sensor-data-access` |
| `aws_iam_role_policy_attachment` | binds the two |

The policy is the one supplied in the spec, with `<my_bucket>` resolved to
`rriv-sensor-data` — the bucket created by
`../../cf/create-s3-tables-bucket.sh`.

## Prerequisites

- Terraform `~> 1.11`, matching `../tigercloud`. This configuration itself only
  needs 1.9+ (cross-variable `validation`).
- AWS credentials in the ambient credential chain with permission to create IAM
  roles and policies. Nothing authenticating is declared in the configuration,
  so no credential reaches state or a `.tfvars` file.
- The ARN of whoever will assume the role — see the next section.

## Usage

```bash
cp terraform.tfvars.example secrets.tfvars   # fill in real values
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan -var-file=secrets.tfvars -out=tfplan
terraform apply tfplan
```

Apply the saved `tfplan` rather than re-running `plan` inside apply, so what you
reviewed is what executes.

```bash
terraform output role_arn      # hand this to the consumer
terraform output policy_json   # diff against the supplied policy
```

## The one input you must supply

`trusted_principal_arns` is required and has no default. A role needs a trust
policy, the spec does not name a trustee, and every candidate default is wrong
in a way that matters:

- Account root (`arn:aws:iam::<acct>:root`) trusts *every* principal in the
  account whose own policy permits `sts:AssumeRole` — a quiet widening.
- A wildcard principal is worse.

So it is left explicit. For the TigerLake integration this is the TigerData-side
role ARN, available from the CloudFormation stack:

```bash
aws cloudformation describe-stacks \
  --stack-name rriv-sensor-data-tables --region us-west-2 \
  --query 'Stacks[0].Outputs'
```

Set `external_id` alongside it whenever the trustee lives in an account you do
not control. That is the documented mitigation for the confused-deputy problem,
where a third party is tricked into assuming your role on someone else's behalf.

## Known issue in the supplied policy

The second statement attaches a `StringLike` condition on `s3:prefix` to both
`s3:ListBucket` and `s3:GetBucketLocation`. Conditions apply to the whole
statement, and **`GetBucketLocation` requests do not carry an `s3:prefix` key**,
so the condition cannot be satisfied and that action is effectively never
allowed. `ListBucket` is unaffected — `*` matches any prefix, including the
empty prefix of a root listing — which makes the condition a no-op there.

Net effect: the condition grants nothing and blocks one of the five actions.
It is reproduced verbatim because it is what the spec specifies. If that was
not intended, split the statement in `iam/main.tf`:

```hcl
statement {
  sid       = "BucketList"
  effect    = "Allow"
  actions   = ["s3:ListBucket"]
  resources = [local.bucket_arn]
}

statement {
  sid       = "BucketLocation"
  effect    = "Allow"
  actions   = ["s3:GetBucketLocation"]
  resources = [local.bucket_arn]
}
```

## Assumptions

- **`<my_bucket>` is `rriv-sensor-data`.** The prompt says "the table
  rriv-sensor-data"; the only bucket in this repo by that name is the one
  `../../cf/create-s3-tables-bucket.sh` creates. Override with `bucket_name`.
- **S3, not S3 Tables.** Worth checking before you apply. That shell script is
  named `create-s3-tables-bucket.sh` and the commit that added it calls the
  result an Iceberg bucket. If `rriv-sensor-data` is genuinely an **S3 Tables**
  bucket, this policy does not reach it: table buckets are addressed as
  `arn:aws:s3tables:<region>:<account>:bucket/<name>` and governed by
  `s3tables:*` actions, not `arn:aws:s3:::<name>` and `s3:*`. The supplied
  policy uses the general-purpose S3 form, so that is what is implemented.
  Confirm with `aws s3tables list-table-buckets --region us-west-2`; if the name
  appears there, the action list and ARN pattern both need to change.
- **Region `us-west-2`.** IAM is global, so this only selects the API endpoint.
  It matches the region of the CloudFormation stack. Override with `aws_region`.
- **No permissions boundary, no session duration limit, no KMS grant.** None
  were requested. If the bucket uses SSE-KMS with a customer-managed key, this
  policy is not sufficient on its own — `kms:GenerateDataKey` and
  `kms:Decrypt` on that key are also needed, either here or in the key policy.
- **Partition read from `aws_partition`** instead of hardcoding `arn:aws:`.
  Renders identically in commercial AWS; stays correct in GovCloud and China.

## Local state: the tradeoff

The spec requires a local backend, so that is what is configured. Unlike
`../tigercloud`, no secret lands in this state file — IAM role and policy
documents are not confidential. What remains:

- No locking, no versioning, no audit trail.
- Not safe for more than one operator.
- `terraform.tfstate` is the only record of what exists. Back it up before any
  apply.

`.gitignore` excludes `*.tfstate*` and `*.tfvars`. Moving to a remote backend
later is `terraform init -migrate-state` after adding a `backend "s3"` block.

## Validation status

**Not run.** No Terraform runtime is installed in this environment
(`terraform`, `tofu`, `tflint`, `trivy`, `checkov` all absent), and `plan`
additionally requires live AWS credentials. The commands under Usage are the
ones to run; treat the configuration as unvalidated until they pass.

## Rollback

`terraform destroy` deletes the role and policy. No data is destroyed — but any
consumer currently assuming the role loses access immediately, and re-creating a
role with the same name produces a **different** `unique_id`, which invalidates
anything pinned to `aws:userid`.

```bash
terraform plan -destroy -var-file=secrets.tfvars
```

Review every resource listed, keep the plan output as evidence, and never use
`-auto-approve`. To remove the role from Terraform's control without deleting
it, use a `removed` block instead of `destroy`.
