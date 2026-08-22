output "role_arn" {
  description = "ARN of the role. This is the value the consumer assumes."
  value       = aws_iam_role.bucket_access.arn
}

output "role_name" {
  description = "Name of the role."
  value       = aws_iam_role.bucket_access.name
}

output "role_unique_id" {
  description = "Stable unique ID of the role, useful in aws:userid conditions."
  value       = aws_iam_role.bucket_access.unique_id
}

output "policy_arn" {
  description = "ARN of the customer-managed access policy."
  value       = aws_iam_policy.bucket_access.arn
}

output "policy_json" {
  description = "Rendered access policy, for diffing against the supplied policy document."
  value       = data.aws_iam_policy_document.bucket_access.json
}
