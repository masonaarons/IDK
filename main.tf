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
resource "aws_lb" "teamred_lb" {
  name               = "red-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.my_sg.id] # Replace my_sg with Security group variable
  subnets            = [aws_subnet.my_subnet1.id, aws_subnet.my_subnet2.id]

  enable_deletion_protection = true

  tags = {
    Name = "red-lb"
  }
}

# Target group for the ALB
resource "aws_lb_target_group" "teamred_tg" {
  name     = "red-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id # Replace my_vpc with active VPC variable 

  health_check {
    enabled             = true
    interval            = 60
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }
}

# Listener for the ALB
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.teamred_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.teamred_tg.arn
  }
}
