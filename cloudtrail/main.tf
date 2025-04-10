resource "aws_cloudtrail" "kungfu_cloudtrail" {
  name                          = "kungfu-trail"
  s3_bucket_name                = aws_s3_bucket.kungfu_s3.bucket
  is_multi_region_trail         = true
  include_global_service_events = true
  enable_log_file_validation    = true
  cloud_watch_logs_group_arn    = aws_cloudwatch_log_group.kungfu_log_group.arn
  cloud_watch_logs_role_arn     = aws_iam_role.kungfu_cloudtrail_role.arn
}

resource "aws_cloudwatch_log_group" "kungfu_log_group" {
  name = "/aws/cloudtrail/kungfu-log-group"
}

resource "aws_iam_role" "kungfu_cloudtrail_role" {
  name = "kungfu-cloudtrail-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "kungfu_cloudtrail_role_policy" {
  name       = "kungfu-cloudtrail-role-policy-attachment"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCloudTrailRole"
  roles      = [aws_iam_role.kungfu_cloudtrail_role.name]
}
