resource "aws_cloudtrail" "kungfu_cloudtrail" {
  name                          = "kungfu-cloudtrail"
  s3_bucket_name                = var.bucket_name
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true
}


resource "aws_iam_role" "kungfu_cloudtrail_role" {
  name = "kungfu-cloudtrail-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "kungfu_cloudtrail_role_policy" {
  name       = "kungfu-cloudtrail-role-policy-attachment"
  roles      = [aws_iam_role.kungfu_cloudtrail_role.name]
  policy_arn = var.cloudtrail_policy_arn  # Correction : on passe la bonne policy créée dans module iam
}
