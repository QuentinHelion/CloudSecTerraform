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

resource "aws_s3_object" "very_secret_upload" {
  bucket  = aws_s3_bucket.kungfu_s3.id
  key     = "very_secret_file.txt"
  content = templatefile("${path.module}/very_secret_file.tpl.txt", { username = var.very_secret_username, secret = var.very_secret_access_key_secret, id = var.very_secret_access_key_id })
}