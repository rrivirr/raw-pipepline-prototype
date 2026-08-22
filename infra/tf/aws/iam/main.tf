# The partition is read rather than hardcoded so the ARNs stay correct outside
# commercial AWS (aws-us-gov, aws-cn). In commercial AWS it renders to exactly
# the "arn:aws:s3:::" prefix the supplied policy uses.
data "aws_partition" "current" {}

locals {
  bucket_arn = "arn:${data.aws_partition.current.partition}:s3:::${var.bucket_name}"
}

# Trust policy. The spec does not include one, but a role cannot exist without
# it. sts:AssumeRole only — this role carries data-plane S3 permissions and has
# no reason to allow session tagging or federated (SAML/OIDC) entry points.
data "aws_iam_policy_document" "assume_role" {
  statement {
    sid     = "AllowTrustedPrincipalsToAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = var.trusted_principal_arns
    }

    dynamic "condition" {
      for_each = var.external_id == null ? [] : [var.external_id]

      content {
        test     = "StringEquals"
        variable = "sts:ExternalId"
        values   = [condition.value]
      }
    }
  }
}

# Access policy. This is the policy supplied in the spec, statement for
# statement, expressed as a policy document so the action names and condition
# keys are schema-checked at plan time instead of shipping as an opaque string.
# Compare against the source with `terraform output policy_json`.
data "aws_iam_policy_document" "bucket_access" {
  # Statement 1 of the supplied policy: object-level read/write, including
  # versioned reads and deletes.
  statement {
    sid    = "ObjectReadWrite"
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
    ]

    resources = ["${local.bucket_arn}/*"]
  }

  # Statement 2 of the supplied policy: bucket-level listing, carrying the
  # s3:prefix condition as specified. Reproduced verbatim — see the
  # "Known issue in the supplied policy" section of ../README.md for why the
  # condition makes s3:GetBucketLocation unusable and what to change if that
  # was not intended.
  statement {
    sid    = "BucketList"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]

    resources = [local.bucket_arn]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["*"]
    }
  }
}

resource "aws_iam_role" "bucket_access" {
  name               = var.role_name
  description        = "Grants S3 read/write access to the ${var.bucket_name} bucket."
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# A customer-managed policy rather than an inline role policy: it is separately
# addressable, versioned by IAM, and attachable to a second role later without
# copying the document.
resource "aws_iam_policy" "bucket_access" {
  name        = var.role_name
  description = "S3 object and bucket permissions for ${var.bucket_name}."
  policy      = data.aws_iam_policy_document.bucket_access.json
}

resource "aws_iam_role_policy_attachment" "bucket_access" {
  role       = aws_iam_role.bucket_access.name
  policy_arn = aws_iam_policy.bucket_access.arn
}
