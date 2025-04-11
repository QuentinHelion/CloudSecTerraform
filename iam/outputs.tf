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

output "temp_admin_role_arn" {
  value = aws_iam_role.temp_admin_role.arn
}

output "flow_logs_role_arn" {
  value = aws_iam_role.flow_logs_role.arn
}

output "firehose_delivery_role_arn" {
  value = aws_iam_role.firehose_delivery_role.arn
}
