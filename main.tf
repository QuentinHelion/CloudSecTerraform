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

# On utilise l'API HTTP pour récupérer l'IP publique de la machine exécutant Terraform
data "http" "myip" {
  url = "http://ipv4.icanhazip.com/"
}

module "ec2_instance" {
  source            = "./ec2_instance"
  ami_id            = data.aws_ami.debian_11.id
  key_name          = "tf-qhel-key"
  instance_name     = var.instance_name
  vpc_id            = module.network.vpc_id
  public_subnet_id  = module.network.public_subnet_id
  my_ip             = trimspace(data.http.myip.response_body)  # Passer l'IP dynamique ici
}

