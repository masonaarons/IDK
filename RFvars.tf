variable "default_tags" {
  type = map(string)
  default = {
    "username" = "redteam"
  }
  description = "This is a response in my terraform testing environment"
}

variable "public_subnet_count" {
  type        = number
  description = "Number of public subnets in VPC"
  default     = 2
}

variable "private_subnet_count" {
  type        = number
  description = "Number of private subnets in VPC"
  default     = 2
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR for VPC"
}

variable "sg_db_ingress" {
  type = map(object({
    port     = number
    protocol = string
    self     = bool
  }))
  default = {
    "postgresql" = {
      port     = 5432 #postgresl db port
      protocol = "tcp"
      self     = true
    }
  }
}

variable "sg_db_egress" {
  type = map(object({
    port     = number
    protocol = string
    self     = bool
  }))
  default = {
    "all" = {
      port     = 0
      protocol = "-1" # signal to every available protocol
      self     = true
    }
  }
}

variable "db_credentials" {
  type      = map(any)
  sensitive = true
  default = {
    username = "username"
    password = "password"
  }
}
#API GATEWAY AND LAMBDA VARIABLES
variable "myregion" {
  description = "The AWS region"
  type        = string
  default     = "us-east-1"
}

variable "accountId" {
  description = "The AWS account ID"
  type        = string
}

variable "lambda_function_name" {
  description = "What to name the lambda function"
  type        = string
  default     = "Currency_Converter"
}

variable "endpoint_path" {
  description = "The GET endpoint path"
  type        = string
  default     = "conversion"
}