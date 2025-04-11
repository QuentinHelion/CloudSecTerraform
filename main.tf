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

# Définir le bucket S3
resource "aws_s3_bucket" "kungfu_s3" {
  bucket = "kungfu-s3-bucket"
  acl    = "private"
}

# Définir le rôle IAM pour Firehose
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

# Définir le module CloudWatch
module "cloudwatch" {
  source      = "./cloudwatch"
  instance_id = module.ec2_instance.instance_id  # Utilise l'output du module ec2_instance
}

# Définir le module CloudTrail
module "cloudtrail" {
  source = "./cloudtrail"
  bucket_name = aws_s3_bucket.kungfu_s3.bucket
}

# Définir le module IAM
module "iam" {
  source      = "./iam"
  username    = "kungfu"
  policy_name = "kungfu"
}

module "network" {
  source = "./network"
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com/"
}

# Définir le module S3 Bucket (si nécessaire)
module "s3_bucket" {
  source                        = "./s3_bucket"
  bucket_name                   = var.bucket_name
  very_secret_access_key_id     = module.iam.access_key_id
  very_secret_access_key_secret = module.iam.access_key_secret
  very_secret_username          = module.iam.username
}

# Définir le module EC2 Instance
module "ec2_instance" {
  source            = "./ec2_instance"
  ami_id            = data.aws_ami.debian_11.id
  key_name          = "tf-qhel-key"
  instance_name     = var.instance_name
  vpc_id            = module.network.vpc_id
  public_subnet_id  = module.network.public_subnet_id
  my_ip             = trimspace(data.http.myip.response_body)
}

resource "aws_kinesis_firehose_delivery_stream" "cloudwatch_firehose" {
  name        = "cloudwatch-to-s3-stream"
  destination = "s3"

  s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = aws_s3_bucket.kungfu_s3.arn
  }
}
