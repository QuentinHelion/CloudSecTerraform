#########################################
# BUCKET S3
#########################################

resource "aws_s3_bucket" "kungfu_s3" {
  bucket = "tf-${var.bucket_name}-bucket"

  tags = {
    Name = "tf-${var.bucket_name}-bucket"
  }
}

#########################################
# BLOCK PUBLIC ACCESS
#########################################

resource "aws_s3_bucket_public_access_block" "kungfu_block_public" {
  bucket = aws_s3_bucket.kungfu_s3.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#########################################
# BUCKET POLICY POUR CLOUDTRAIL
#########################################

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "cloudtrail_bucket_policy" {
  bucket = aws_s3_bucket.kungfu_s3.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AWSCloudTrailAclCheck"
        Effect    = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action    = "s3:GetBucketAcl"
        Resource  = "arn:aws:s3:::${aws_s3_bucket.kungfu_s3.bucket}"
      },
      {
        Sid       = "AWSCloudTrailWrite"
        Effect    = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action    = "s3:PutObject"
        Resource  = "arn:aws:s3:::${aws_s3_bucket.kungfu_s3.bucket}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

#########################################
# VERY SECRET FILE UPLOAD
#########################################

resource "aws_s3_object" "very_secret_upload" {
  bucket  = aws_s3_bucket.kungfu_s3.id
  key     = "very_secret_file.txt"

  content = templatefile("${path.module}/very_secret_file.tpl.txt", {
    username = var.very_secret_username
    secret   = var.very_secret_access_key_secret
    id       = var.very_secret_access_key_id
  })
}
