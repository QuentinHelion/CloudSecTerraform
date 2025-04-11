output "cloudwatch_alarm_name" {
  value = aws_cloudwatch_metric_alarm.cpu_utilization.alarm_name
}

output "cloudwatch_dashboard_name" {
  value = aws_cloudwatch_dashboard.ec2_dashboard.dashboard_name
}
