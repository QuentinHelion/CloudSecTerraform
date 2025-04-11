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

resource "aws_key_pair" "kungfu_key" {
  key_name   = "tf-${var.instance_name}-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCbwYrUlaGhORKNmnopt+IGkDhWV5locytSs+uNZztbrc8+8R4m68yheTOLe5t0JJx1DzmODfFu00PyIcUCx3eAPB3aYcOznCAg50Cu1rqyU9NMeiyV+24Mei9kMGHUVffe7eYor2MgSlCJ8GtPApdTvTBJLxbkVNKoLsLw5EJTLL0OXvPEXW8KvJ3bMkYgGClAuDMEvg0jsHlmHVqOEpvnq0T5hJ8rzAa+kT24yc7PUqT/nKr66I65zWpkhoCavBaOgMIVz0tEOmpkw0d8sjRJBUZcOxjmUQDMw+2wsQMCkmK5jSOFOG6AMnUr99WTcqzjl0yp7g37l70hvf+uGmtR"
}

resource "aws_iam_instance_profile" "kungfu_profile" {
  name = "tf-${var.instance_name}-instance-profile"
  role = aws_iam_role.kungfu_role.name
}

resource "aws_instance" "kungfu_ec2" {
  ami                  = var.ami_id
  instance_type        = "t2.micro"
  vpc_security_group_ids = [aws_security_group.kungfu_sg.id]
  key_name             = aws_key_pair.kungfu_key.id
  iam_instance_profile = aws_iam_instance_profile.kungfu_profile.name
  user_data            = file("${path.module}/scripts/install_lab.sh")
  subnet_id            = var.public_subnet_id
  associate_public_ip_address = true
  root_block_device {
    delete_on_termination = true
  }
  tags = {
    Name = "tf-${var.instance_name}-ec2"
  }
  metadata_options {
    http_tokens = "required"  
    http_endpoint = "enabled"
  }
}


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

resource "aws_security_group" "kungfu_sg" {
  name        = "tf-${var.instance_name}-sg"
  description = "Allow SSH & HTTPS traffic from current IP"
  vpc_id      = var.vpc_id  # Référence au VPC du module 'network'

  ingress {
    description = "Allow SSH & HTTPS traffic from current IP"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]  # Utiliser la variable my_ip
  }

  egress {
    description = "Allow all egress"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tf-${var.instance_name}-sg"
  }
}


resource "aws_iam_role" "ec2_cloudwatch_role" {
  name = "ec2-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "attach_cloudwatch_policy" {
  name       = "attach-cloudwatch-policy"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  roles      = [aws_iam_role.ec2_cloudwatch_role.name]
}
