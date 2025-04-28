variable "region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "ec2_key_name" {
  description = "Name of the SSH key pair for EC2"
  type        = string
}

variable "iam_username" {
  description = "IAM username to create"
  type        = string
}

variable "policy_name" {
  description = "Name of the IAM policy to create"
  type        = string
}

variable "ami_owner_id" {
  description = "AWS account ID owning the official Debian AMIs"
  type        = string
  default     = "136693071363"  # Debian officiel
}

variable "firehose_role_name" {
  description = "Name of the IAM role for Firehose"
  type        = string
  default     = "firehose-role"
}

variable "firehose_stream_name" {
  description = "Name of the Firehose delivery stream"
  type        = string
  default     = "cloudwatch-to-s3-stream"
}



######################################
# NETWORK VARIABLES
######################################

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
}

variable "availability_zone" {
  description = "Availability Zone for the subnets"
  type        = string
}

variable "public_subnet_name" {
  description = "Name tag for the public subnet"
  type        = string
}

variable "private_subnet_name" {
  description = "Name tag for the private subnet"
  type        = string
}

variable "internet_gateway_name" {
  description = "Name tag for the Internet Gateway"
  type        = string
}

variable "public_route_table_name" {
  description = "Name tag for the public route table"
  type        = string
}

variable "private_route_table_name" {
  description = "Name tag for the private route table"
  type        = string
}
