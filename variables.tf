variable "region" {
  description = "Region to be used."
  type        = string
  default     = "eu-west-3"
}

variable "instance_name" {
  description = "Name of the EC2 instance."
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket."
  type        = string
}