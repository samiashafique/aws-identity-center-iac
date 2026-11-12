output "instance_arn" {
  description = "The ARN of the IAM Identity Center instance"
  value       = local.instance_arn
}

output "identity_store_id" {
  description = "The ID of the Identity Store used by the IAM Identity Center instance"
  value       = local.identity_store_id
}
