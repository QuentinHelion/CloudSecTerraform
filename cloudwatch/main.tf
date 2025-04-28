resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  alarm_name          = "High-CPU-Utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alarm when CPU exceeds 80%"
  dimensions = {
    InstanceId = var.instance_id
  }
  actions_enabled = true
}

resource "aws_cloudwatch_dashboard" "ec2_dashboard" {
  dashboard_name = "EC2-Dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric",
        x    = 0,
        y    = 0,
        width = 12,
        height = 6,
        properties = {
          metrics = [
            [ "AWS/EC2", "CPUUtilization", "InstanceId", var.instance_id ]
          ],
          title       = "CPU Utilization",
          region      = var.aws_region,
          annotations = {} # Ajout obligatoire même si vide
        }
      }
    ]
  })
}
