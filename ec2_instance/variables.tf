variable "instance_name" {
  description = "Name of the instance"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "public_subnet_id" {
  description = "The public subnet ID"
  type        = string
}

variable "my_ip" {
  description = "Your current public IP address"
  type        = string
}