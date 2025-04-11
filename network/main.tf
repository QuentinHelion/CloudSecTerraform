# Créer le VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "tf-main-vpc"
  }
}

# Créer le subnet public
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-3a"

  tags = {
    Name = "tf-public-subnet"
  }
}

# Créer le subnet privé
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-3a"

  tags = {
    Name = "tf-private-subnet"
  }
}

# Créer l'Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main-gateway"
  }
}

# Créer la table de routage publique
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-rt"
  }
}

# Associer la table de routage publique au subnet public
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public.id
}

# Créer une route table privée (si nécessaire)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "private-rt"
  }
}

resource "aws_kinesis_firehose_delivery_stream" "firehose" {
  name        = "my-firehose-stream"
  destination = "s3"
  
  s3_configuration {
    role_arn   = "arn:aws:iam::421751520950:role/firehose-role"
    bucket_arn = "arn:aws:s3:::qhel"
  }
}

# Associer la route table privée au subnet privé
resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private.id
}

resource "aws_flow_log" "flow_logs" {
  log_destination      = aws_kinesis_firehose_delivery_stream.firehose.arn
  log_destination_type = "kinesis-data-firehose"
  traffic_type         = "ALL"
  iam_role_arn         = var.flow_logs_role_arn
  vpc_id               = var.vpc_id
}

