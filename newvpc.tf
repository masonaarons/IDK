terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "redteam"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}
provider "aws" {
  region = "us-east-1"
}

# VPC
resource "aws_vpc" "red_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "RedTeam-VPC"
  }
}

# Public Subnet
resource "aws_subnet" "Red_PublicSubnet" {
  vpc_id                  = aws_vpc.red_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "RedTeam-PublicSubnet"
  }
}

# Private Subnet
resource "aws_subnet" "Red_PrivateSubnet" {
  vpc_id            = aws_vpc.red_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "RedTeam-PrivateSubnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "Red_IGW" {
  vpc_id = aws_vpc.red_vpc.id
  tags = {
    Name = "RedTeam-IGW"
  }
}

# Public Security Group
resource "aws_security_group" "Red_PublicSG" {
  vpc_id = aws_vpc.red_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Public Route Table
resource "aws_route_table" "Red_PublicRT" {
  vpc_id = aws_vpc.red_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Red_IGW.id
  }
}
