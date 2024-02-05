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
  default_tags {
    
  }
}

resource "aws_instance" "redteam" {
  ami = "ami-0277155c3f0ab2930"

  instance_type = "t3.micro"
  # Needs to be changed to presenter or keys for role (TBD)
  key_name = "scarreras"

  tags = {
    Name = "redteam"
  }
}