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

variable "my_ip" {
  description = "Your current IP address in CIDR notation (e.g., 1.2.3.4/32)"
  type        = string
}