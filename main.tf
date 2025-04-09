module "ec2_instance" {
  source            = "./ec2_instance"
  instance_name     = var.instance_name
  vpc_id            = module.network.vpc_id
  public_subnet_id  = module.network.public_subnet_id
  ami            = data.aws_ami.debian_11.id
  my_ip             = chomp(data.http.myip.body)
}

module "s3_bucket" {
  source                        = "./s3_bucket"
  bucket_name                   = var.bucket_name
  very_secret_access_key_id     = module.iam.access_key_id
  very_secret_access_key_secret = module.iam.access_key_secret
  very_secret_username          = module.iam.username
}

module "iam" {
  source      = "./iam"
  username    = "kungfu"
  policy_name = "kungfu"
}

module "kms" {
  source     = "./kms"
  user_arns  = [module.iam.user_arn]
}

module "network" {
  source = "./network"
}


data "http" "myip" {
  url = "http://ipv4.icanhazip.com/"
}
