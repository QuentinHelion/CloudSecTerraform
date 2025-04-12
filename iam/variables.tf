variable "username" {
  type = string
}
variable "policy_name" {
  type = string
}
variable "user_groups" {
  description = "Map of users to groups"
  type        = map(list(string))
}

variable "aws_region" {
  type        = string
  default     = "eu-west-3" # ou ce que tu veux
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

variable "flowlog_bucket_arn" {
  description = "ARN du bucket S3 pour recevoir les logs"
  type        = string
}

