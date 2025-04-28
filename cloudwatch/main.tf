#########################################
# CLOUDWATCH ALARM (CPU UTILIZATION)
#########################################

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

#########################################
# CLOUDWATCH DASHBOARD
#########################################

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
            ["AWS/EC2", "CPUUtilization", "InstanceId", var.instance_id]
          ],
          title       = "CPU Utilization",
          region      = var.aws_region,
          annotations = {}
        }
      }
    ]
  })
}

#########################################
# CLOUDWATCH LOG GROUP
#########################################

resource "aws_cloudwatch_log_group" "ec2_log_group" {
  name              = "/aws/ec2/cpu-monitoring"
  retention_in_days = 7

  tags = {
    Name = "ec2-log-group"
  }
}

#########################################
# IAM ROLE FOR LOGS ➔ FIREHOSE
#########################################

resource "aws_iam_role" "cloudwatch_to_firehose_role" {
  name = "tf-cloudwatch-to-firehose-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "logs.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "cloudwatch_to_firehose_policy" {
  role = aws_iam_role.cloudwatch_to_firehose_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "firehose:PutRecord",
          "firehose:PutRecordBatch"
        ],
        Resource = var.firehose_arn
      }
    ]
  })
}

#########################################
# CLOUDWATCH LOG SUBSCRIPTION FILTER
#########################################

resource "aws_cloudwatch_log_subscription_filter" "logs_to_firehose" {
  name            = "logs-to-firehose"
  log_group_name  = aws_cloudwatch_log_group.ec2_log_group.name
  destination_arn = var.firehose_arn
  filter_pattern  = ""

  role_arn = aws_iam_role.cloudwatch_to_firehose_role.arn

  depends_on = [
    aws_cloudwatch_log_group.ec2_log_group,
    aws_iam_role.cloudwatch_to_firehose_role,
    aws_iam_role_policy.cloudwatch_to_firehose_policy
  ]
}
