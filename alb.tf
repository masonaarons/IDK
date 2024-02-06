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
    tags = var.default-tags
  }
}


# Application Load Balancer (ALB)
resource "aws_lb" "redteam_lb" {
  name               = "red-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.Red_PublicSG.id, aws_security_group.Red_PrivateSG.id] # Replace my_sg with Security group variable
  subnets            = [aws_subnet.Red_PublicSubnet.id, aws_subnet.Red_PrivateSubnet.id] # Replace my_subnet with Subnet variables

  enable_deletion_protection = false

  tags = {
    Name = "red-lb"
  }
}

# Target group for the ALB
resource "aws_lb_target_group" "redteam_tg" {
  name     = "redteam-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.red_vpc.id # Replace my_vpc with active VPC variable 

  health_check {
    enabled             = true
    interval            = 60
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5 
    unhealthy_threshold = 2 # Can be changed to meet the needs of the application
  }
}

# Listener for the ALB
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.redteam_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.redteam_tg.arn
  }
}
