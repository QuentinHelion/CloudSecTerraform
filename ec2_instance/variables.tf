variable "public_key" {
  description = "Public SSH key to connect to the EC2 instance"
  type        = string
}

variable "my_ip" {
  description = "Your public IP for SSH access"
  type        = string
}

variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
}

variable "ami_id" {
  description = "AMI ID to launch the EC2 instance"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the EC2 instance is deployed"
  type        = string
}

variable "public_subnet_id" {
  description = "Subnet ID for the EC2 instance"
  type        = string
}
