output "role_arn" {
  description = "ARN of the role. This is the value the consumer assumes."
  value       = module.iam.role_arn
}

output "role_name" {
  description = "Name of the role."
  value       = module.iam.role_name
}

output "policy_arn" {
  description = "ARN of the customer-managed policy attached to the role."
  value       = module.iam.policy_arn
}

output "policy_json" {
  description = "Rendered access policy, for diffing against the supplied policy document."
  value       = module.iam.policy_json
}
