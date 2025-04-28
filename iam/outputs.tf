output "username" {
  value = aws_iam_user.kungfu_user.name
}

output "access_key_id" {
  value = aws_iam_access_key.kungfu_access_key.id
}

output "access_key_secret" {
  value = aws_iam_access_key.kungfu_access_key.secret
}

output "user_arn" {
  description = "ARN de l'utilisateur IAM créé"
  value       = aws_iam_user.kungfu_user.arn
}

output "cloudtrail_policy_arn" {
  description = "ARN of the policy for CloudTrail"
  value       = aws_iam_policy.cloudtrail_policy.arn
}

output "temp_admin_role_arn" {
  value = aws_iam_role.temp_admin_role.arn
}