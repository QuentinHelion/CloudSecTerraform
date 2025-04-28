variable "username" {
  type = string
}

variable "policy_name" {
  type = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket used by CloudTrail"
  type        = string
}
