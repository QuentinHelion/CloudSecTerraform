# modules/network/variables.tf

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "public_subnet_az" {
  description = "Availability Zone for the public subnet"
  type        = string
  default     = "eu-west-3a"
}

variable "private_subnet_az" {
  description = "Availability Zone for the private subnet"
  type        = string
  default     = "eu-west-3b"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the EC2"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Key name for EC2"
  type        = string
}
