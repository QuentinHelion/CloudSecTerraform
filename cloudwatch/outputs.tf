output "cloudwatch_alarm_name" {
  description = "Name of the CloudWatch CPU utilization alarm"
  value       = aws_cloudwatch_metric_alarm.cpu_utilization.alarm_name
}

output "cloudwatch_dashboard_name" {
  description = "Name of the CloudWatch EC2 dashboard"
  value       = aws_cloudwatch_dashboard.ec2_dashboard.dashboard_name
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group used for EC2 monitoring"
  value       = aws_cloudwatch_log_group.ec2_log_group.name
}
