######################################
# DATA SOURCES
######################################

data "aws_ami" "debian_11" {
  most_recent = true
  owners      = [var.ami_owner_id]
  filter {
    name   = "name"
    values = ["debian-11-amd64-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Récupérer mon IP publique
data "http" "myip" {
  url = "http://ipv4.icanhazip.com/"
}

######################################
# NETWORK MODULE
######################################

module "network" {
  source = "./network"


  vpc_cidr_block         = var.vpc_cidr_block
  vpc_name               = var.vpc_name
  public_subnet_cidr     = var.public_subnet_cidr
  private_subnet_cidr    = var.private_subnet_cidr
  availability_zone      = var.availability_zone
  public_subnet_name     = var.public_subnet_name
  private_subnet_name    = var.private_subnet_name
  internet_gateway_name  = var.internet_gateway_name
  public_route_table_name  = var.public_route_table_name
  private_route_table_name = var.private_route_table_name
}

######################################
# EC2 INSTANCE MODULE
######################################

module "ec2_instance" {
  source            = "./ec2_instance"

  ami_id            = data.aws_ami.debian_11.id
  public_key        = var.public_key
  instance_name     = var.instance_name
  vpc_id            = module.network.vpc_id
  public_subnet_id  = module.network.public_subnet_id
  my_ip             = trimspace(data.http.myip.response_body)
}

######################################
# S3 BUCKET MODULE
######################################

module "s3_bucket" {
  source                        = "./s3_bucket"

  bucket_name                   = var.bucket_name
  very_secret_access_key_id     = module.iam.access_key_id
  very_secret_access_key_secret = module.iam.access_key_secret
  very_secret_username          = module.iam.username
}

######################################
# IAM MODULE
######################################

module "iam" {
  source = "./iam"

  username         = var.iam_username
  policy_name      = var.iam_policy_name
  s3_bucket_name   = module.s3_bucket.bucket_name

  user_groups      = var.iam_user_groups
  user_policies    = var.iam_user_policies
  assume_role_user = var.iam_assume_role_user
}

######################################
# CLOUDWATCH MODULE
######################################

module "cloudwatch" {
  source = "./cloudwatch"

  instance_id = module.ec2_instance.instance_id
  aws_region  = var.region
  firehose_arn = aws_kinesis_firehose_delivery_stream.cloudwatch_firehose.arn
}

######################################
# CLOUDTRAIL MODULE
######################################

module "cloudtrail" {
  source               = "./cloudtrail"
  
  bucket_name          = module.s3_bucket.bucket_name
  cloudtrail_policy_arn = module.iam.cloudtrail_policy_arn
}

######################################
# FIREHOSE DELIVERY STREAM
######################################

# Rôle IAM pour Firehose
resource "aws_iam_role" "firehose_role" {
  name = var.firehose_role_name

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

# Firehose Stream : CloudWatch -> S3
resource "aws_kinesis_firehose_delivery_stream" "cloudwatch_firehose" {
  name        = var.firehose_stream_name
  destination = "s3"

  s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = module.s3_bucket.bucket_arn
  }
}
