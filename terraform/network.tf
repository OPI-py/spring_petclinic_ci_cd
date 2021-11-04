provider "aws" {
  profile = var.profile
  region  = var.region
  alias   = "region"
}

#Create new VPC in eu-central-1
resource "aws_vpc" "vpc_eucentral" {
  provider             = aws.region
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "vpc-jenkins-master"
  }
}

#Create IGW
resource "aws_internet_gateway" "igw" {
  provider = aws.region
  vpc_id   = aws_vpc.vpc_eucentral.id
}

#Create route table
resource "aws_route_table" "internet_route" {
  provider = aws.region
  vpc_id   = aws_vpc.vpc_eucentral.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "Region-RT"
  }
}

#Overwrite default route table of VPC with route table entries
resource "aws_main_route_table_association" "set-master-default-rt-assoc" {
  provider       = aws.region
  vpc_id         = aws_vpc.vpc_eucentral.id
  route_table_id = aws_route_table.internet_route.id
}

#Create subnet in eu-central-1
#resource "aws_subnet" "subnet_1" {
#  provider          = aws.region
#  availability_zone = var.azone
#  vpc_id            = aws_vpc.vpc_eucentral.id
#  cidr_block        = "10.0.1.0/24"
#}

#Create subnet2 in eu-central-1
resource "aws_subnet" "subnet_2" {
  provider          = aws.region
  availability_zone = var.azone
  vpc_id            = aws_vpc.vpc_eucentral.id
  cidr_block        = "10.0.2.0/24"
}

#Create SG for allowing TCP/8080 from * and TCP/22 from trusted_ip
#resource "aws_security_group" "jenkins-sg" {
#  provider    = aws.region
#  name        = "jenkins-sg"
#  description = "Allow TCP/8080 & TCP/22"
#  vpc_id      = aws_vpc.vpc_eucentral.id
#  ingress {
#    description = "Allow 22"
#    from_port   = 22
#    to_port     = 22
#    protocol    = "tcp"
#    cidr_blocks = [var.trusted_ip]
#  }
#  ingress {
#    description = "Allow all on port 8080"
#    from_port   = 8080
#    to_port     = 8080
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#  ingress {
#    description = "Allow traffic from subnet1"
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["10.0.2.0/24"]
#  }
#  egress {
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#}

#Create SG2 for allowing TCP/22 from trusted_ip
resource "aws_security_group" "jenkins-sg-workers" {
  provider    = aws.region
  name        = "jenkins-sg-workers"
  description = "Allow TCP/22 and subnet1"
  vpc_id      = aws_vpc.vpc_eucentral.id
#  ingress {
#    description = "Allow all"
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
  ingress {
    description = "Allow 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.trusted_ip]
  }
#  ingress {
#    description = "Allow traffic from subnet2"
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["10.0.1.0/24"]
#  }
  ingress {
    description = "Allow 80 from anywhere for redirection"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Create SG for LB, only TCP/80, TCP/443 and access to jenkins-sg
#resource "aws_security_group" "lb-sg" {
#  provider    = aws.region
#  name        = "lb-sg"
#  description = "Allow TCP/443"
#  vpc_id      = aws_vpc.vpc_eucentral.id
#  ingress {
#    description = "Allow 443"
#    from_port   = 443
#    to_port     = 443
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#  ingress {
#    description = "Allow 80 from anywhere for redirection"
#    from_port   = 80
#    to_port     = 80
#    protocol    = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#  ingress {
#    description     = "Allow traffic to jenkins-sg"
#    from_port       = 0
#    to_port         = 0
#    protocol        = "tcp"
#    security_groups = [aws_security_group.jenkins-sg.id]
#  }
#  egress {
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#}
