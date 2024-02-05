terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
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

# IGW 
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "RedTeam-IGW"
  }
}

