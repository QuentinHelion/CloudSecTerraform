variable "username" {
  description = "Name of the IAM user"
  type        = string
}

variable "policy_name" {
  description = "Name of the IAM user policy"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket used by CloudTrail"
  type        = string
}

variable "user_groups" {
  description = "Map of users to groups"
  type        = map(list(string))
}

variable "user_policies" {
  description = "Map of users to policies"
  type        = map(list(string))
}

variable "assume_role_user" {
  description = "The user who will be able to assume the temp admin role"
  type        = string
  default     = "tf-test1-user"  # Example, you can change this value dynamically
}