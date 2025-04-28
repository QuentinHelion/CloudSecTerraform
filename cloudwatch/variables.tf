variable "instance_id" {
  description = "L'ID de l'instance EC2 pour surveiller la métrique CPUUtilization"
  type        = string
}

variable "aws_region" {
  description = "AWS Region where resources are deployed"
  type        = string
}