output "instance_ip_addr" {
  value = aws_eip.kungfu_eip.public_ip
}

