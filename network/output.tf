#########################################
# VPC OUTPUT
#########################################

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main_vpc.id
}

#########################################
# PUBLIC SUBNET OUTPUT
#########################################

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = aws_subnet.public_subnet.id
}

#########################################
# PRIVATE SUBNET OUTPUT
#########################################

output "private_subnet_id" {
  description = "The ID of the private subnet"
  value       = aws_subnet.private_subnet.id
}