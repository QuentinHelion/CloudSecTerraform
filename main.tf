data "aws_ami" "debian_11" {
  most_recent = true
  owners      = ["136693071363"]
  filter {
    name   = "name"
    values = ["debian-11-amd64-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com/"
}

module "network" {
  source = "./network"
}

module "ec2_instance" {
  source            = "./ec2_instance"
  ami_id            = data.aws_ami.debian_11.id
  key_name          = "tf-qhel-key"
  instance_name     = var.instance_name
  vpc_id            = module.network.vpc_id
  public_subnet_id  = module.network.public_subnet_id
  my_ip             = trimspace(data.http.myip.response_body)
}

# Module S3 Bucket principal
module "s3_bucket" {
  source                        = "./s3_bucket"
  bucket_name                   = var.bucket_name
  very_secret_access_key_id     = module.iam.access_key_id
  very_secret_access_key_secret = module.iam.access_key_secret
  very_secret_username          = module.iam.username
}

# IAM Module
module "iam" {
  source      = "./iam"
  username    = "kungfu"
  policy_name = "kungfu"
  bucket_name = module.s3_bucket.bucket_name    # Correction ici
}

# CloudWatch Module
module "cloudwatch" {
  source      = "./cloudwatch"
  instance_id = module.ec2_instance.instance_id
  aws_region  = var.region
}

# CloudTrail Module
module "cloudtrail" {
  source      = "./cloudtrail"
  bucket_name = module.s3_bucket.bucket_name    # Correction ici
  cloudtrail_policy_arn = module.iam.cloudtrail_policy_arn
}

# Firehose role
resource "aws_iam_role" "firehose_role" {
  name = "firehose-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      },
    ]
  })
}

# Firehose stream
resource "aws_kinesis_firehose_delivery_stream" "cloudwatch_firehose" {
  name        = "cloudwatch-to-s3-stream"
  destination = "s3"

  s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = module.s3_bucket.bucket_arn    # Correction ici
  }
}
