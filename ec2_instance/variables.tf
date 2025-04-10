variable "key_name" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_name" {
  type = string
}

variable "my_ip" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_id" {
  description = "ID du subnet public créé par le module network"
  type        = string
}
