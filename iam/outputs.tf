output "username" {
  value = aws_iam_user.kungfu_user.name
}

output "access_key_id" {
  value = aws_iam_access_key.kungfu_access_key.id
}

output "access_key_secret" {
  value = aws_iam_access_key.kungfu_access_key.secret
}