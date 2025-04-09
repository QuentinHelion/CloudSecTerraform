output "kms_key_id" {
  value       = aws_kms_key.kungfu_access_key.key_id
  description = "ID de la clé KMS"
}

output "kms_key_arn" {
  value       = aws_kms_key.kungfu_access_key.arn
  description = "ARN de la clé KMS"
}
