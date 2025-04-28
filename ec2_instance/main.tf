#########################################
# AMI DEBIAN
#########################################

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

#########################################
# KEY PAIR
#########################################

resource "aws_key_pair" "kungfu_key" {
  key_name   = "tf-${var.instance_name}-key"
  public_key = var.public_key
}

#########################################
# IAM ROLE + CLOUDWATCH POLICY
#########################################

resource "aws_iam_role" "ec2_cloudwatch_role" {
  name = "ec2-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "attach_cloudwatch_policy" {
  name       = "attach-cloudwatch-policy"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  roles      = [aws_iam_role.ec2_cloudwatch_role.name]
}

resource "aws_iam_instance_profile" "kungfu_profile" {
  name = "tf-${var.instance_name}-instance-profile"
  role = aws_iam_role.ec2_cloudwatch_role.name
}

#########################################
# INSTANCE EC2
#########################################

resource "aws_instance" "kungfu_ec2" {
  ami                         = var.ami_id
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.kungfu_sg.id]
  key_name                    = aws_key_pair.kungfu_key.id
  iam_instance_profile        = aws_iam_instance_profile.kungfu_profile.name
  user_data                   = file("${path.module}/scripts/install_lab.sh")
  subnet_id                   = var.public_subnet_id
  associate_public_ip_address = true

  root_block_device {
    delete_on_termination = true
  }

  tags = {
    Name = "tf-${var.instance_name}-ec2"
  }

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }
}

#########################################
# ELASTIC IP
#########################################

resource "aws_eip" "kungfu_eip" {
  vpc = true

  tags = {
    Name = "tf-${var.instance_name}-eip"
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.kungfu_ec2.id
  allocation_id = aws_eip.kungfu_eip.id
}

#########################################
# SECURITY GROUP
#########################################

resource "aws_security_group" "kungfu_sg" {
  name        = "tf-${var.instance_name}-sg"
  description = "Allow SSH & HTTPS traffic from current IP"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow SSH & HTTPS traffic from my IP"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tf-${var.instance_name}-sg"
  }
}
