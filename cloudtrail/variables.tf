variable "bucket_name" {
  description = "Name of the S3 bucket where CloudTrail will store logs"
  type        = string
}

variable "cloudtrail_policy_arn" {
  description = "ARN of the IAM policy that allows CloudTrail to interact with S3 and CloudWatch"
  type        = string
}
