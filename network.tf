
#vpc
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "guide-tfe-es-vpc" {
  cidr_block           = var.vpc_network
  enable_dns_hostnames = true
  tags = {
    "name" = "guide-tfe-es-vpc"
  }
}

#subnet
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "guide-tfe-es-sub" {
  vpc_id                  = aws_vpc.guide-tfe-es-vpc.id
  cidr_block              = var.subnet
  map_public_ip_on_launch = true
  availability_zone       = var.az1
  tags = {
    "name" = "guide-tfe-es-pub-sub"
  }
}

#AWS Subnet for db
resource "aws_subnet" "guide-tfe-es-sub-db-1a" {
  vpc_id            = aws_vpc.guide-tfe-es-vpc.id
  availability_zone = var.az1
  cidr_block        = var.db_subnet_az1
  tags = {
    "name" = "guide-tfe-es-pub-sub"
  }
}

resource "aws_subnet" "guide-tfe-es-sub-db-1b" {
  vpc_id            = aws_vpc.guide-tfe-es-vpc.id
  availability_zone = var.az2
  cidr_block        = var.db_subnet_az2
  tags = {
    "name" = "guide-tfe-es-pub-sub"
  }
}

#AWS IGW
resource "aws_internet_gateway" "guide-tfe-es-igw" {
  vpc_id = aws_vpc.guide-tfe-es-vpc.id

  tags = {
    Name = "guide-tfe-es-igw"
  }
}

#AWS RT
resource "aws_route_table" "guide-tfe-es-pub-rt" {
  vpc_id = aws_vpc.guide-tfe-es-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.guide-tfe-es-igw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.guide-tfe-es-igw.id
  }

  tags = {
    Name = "guide-tfe-es-pub-rt"
  }
}


resource "aws_route_table" "guide-tfe-es-pri-rt" {
  vpc_id = aws_vpc.guide-tfe-es-vpc.id

  tags = {
    Name = "guide-tfe-es-pri-rt"
  }
}

resource "aws_route_table_association" "guide-tfe-es-pub-rt-asc" {
  subnet_id      = aws_subnet.guide-tfe-es-sub.id
  route_table_id = aws_route_table.guide-tfe-es-pub-rt.id
}

resource "aws_eip" "bar" {
  vpc = true

  instance                  = aws_instance.guide-tfe-es-ec2.id
  associate_with_private_ip = aws_instance.guide-tfe-es-ec2.private_ip
}
