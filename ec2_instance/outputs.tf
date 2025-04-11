output "instance_ip_addr" {
  value = aws_eip.kungfu_eip.public_ip
}

output "instance_id" {
  value = aws_instance.kungfu_ec2.id
}
