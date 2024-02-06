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
    tags = var.default_tags
  }
}

# Application Load Balancer (ALB)
resource "aws_lb" "redteam_lb" {
  name               = "red-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.my_sg.id] # Replace my_sg with Security group variable
  subnets            = [aws_subnet.my_subnet1.id, aws_subnet.my_subnet2.id] # Replace my_subnet with Subnet variables

  enable_deletion_protection = true

  tags = {
    Name = "red-lb"
  }
}

# Target group for the ALB
resource "aws_lb_target_group" "redteam_tg" {
  name     = "redteam-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id # Replace my_vpc with active VPC variable 

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

resource "aws_lambda_function" "example_lambda" {
  function_name = var.lambda_function_name
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_role.arn
  handler       = "main.lambda_handler"
  filename      = "my-deployment-package.zip"
  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.example,
  ]
}


resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_iam_role" "lambda_role" {
  name               = "lambda_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_api_gateway_rest_api" "example_api" {
  name = "redteam_api"
}

resource "aws_api_gateway_resource" "example_resource" {
  rest_api_id = aws_api_gateway_rest_api.example_api.id
  parent_id   = aws_api_gateway_rest_api.example_api.root_resource_id
  path_part   = var.endpoint_path
}

resource "aws_api_gateway_method" "example_method" {
  rest_api_id   = aws_api_gateway_rest_api.example_api.id
  resource_id   = aws_api_gateway_resource.example_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# resource "aws_api_gateway_method" "example_method2" {
#   rest_api_id   = aws_api_gateway_rest_api.example_api.id
#   resource_id   = aws_api_gateway_resource.example_resource.id
#   http_method   = "POST"
#   authorization = "NONE"
# }

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.example_api.id
  resource_id             = aws_api_gateway_resource.example_resource.id
  http_method             = aws_api_gateway_method.example_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.example_lambda.invoke_arn
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.myregion}:${var.accountId}:${aws_api_gateway_rest_api.example_api.id}/*/${aws_api_gateway_method.example_method.http_method}${aws_api_gateway_resource.example_resource.path}"
}

resource "aws_api_gateway_deployment" "example" {
  rest_api_id = aws_api_gateway_rest_api.example_api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.example_api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_api_gateway_method.example_method, aws_api_gateway_integration.integration]

}

resource "aws_api_gateway_stage" "example" {
  deployment_id = aws_api_gateway_deployment.example.id
  rest_api_id   = aws_api_gateway_rest_api.example_api.id
  stage_name    = "dev"
}