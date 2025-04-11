resource "aws_s3_bucket" "kungfu_s3" {
  bucket = "tf-${var.bucket_name}-bucket"
}

resource "aws_s3_bucket_public_access_block" "kungfu_block_public" {
  bucket = aws_s3_bucket.kungfu_s3.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Créer un fichier avec les informations d'identification dans S3
resource "aws_s3_object" "very_secret_upload" {
  bucket  = aws_s3_bucket.kungfu_s3.id
  key     = "very_secret_file.txt"
  content = templatefile("${path.module}/very_secret_file.tpl.txt", {
    username = var.very_secret_username
    secret   = var.very_secret_access_key_secret
    id       = var.very_secret_access_key_id
  })
}

resource "aws_kinesis_firehose_delivery_stream" "cloudwatch_to_s3" {
  name        = "cloudwatch-to-s3"
  destination = "s3"

  s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = aws_s3_bucket.kungfu_s3.arn
  }
}

resource "aws_iam_role" "firehose_role" {
  name = "firehose-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "firehose_policy_attachment" {
  name       = "firehose-policy-attachment"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  roles      = [aws_iam_role.firehose_role.name]
}
