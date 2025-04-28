output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.kungfu_s3.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.kungfu_s3.arn
}
