resource "aws_kinesis_firehose_delivery_stream" "firehose" {
  name        = "vpc-flow-logs-firehose"
  destination = "s3"

  s3_configuration {
    role_arn           = var.iam_role_arn
    bucket_arn         = var.bucket_arn

    #buffering_interval = 300  # 5 minutes
    #buffering_size     = 5    # 5 MB
    
    compression_format = "UNCOMPRESSED"
  }

  tags = {
    Environment = "production"
    Service     = "vpc-flowlogs"
  }
}
