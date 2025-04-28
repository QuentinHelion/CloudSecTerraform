variable "username" {
  description = "Username for the base kungfu user"
  type        = string
}

variable "policy_name" {
  description = "Name for the kungfu policy"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 Bucket name for CloudTrail logs"
  type        = string
}

variable "user_groups" {
  description = "Mapping of IAM users to groups"
  type        = map(list(string))
}

variable "user_policies" {
  description = "Mapping of IAM users to their policy names"
  type        = map(list(string))
}

variable "assume_role_user" {
  description = "IAM user allowed to assume the temp admin role"
  type        = string
}
