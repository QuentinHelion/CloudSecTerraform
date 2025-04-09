module "ec2_instance" {
  source        = "./ec2_instance"
  my_ip         = chomp(data.http.myip.body)
  instance_name = var.instance_name
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

data "http" "myip" {
  url = "http://ipv4.icanhazip.com/"
}
