variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_name" {
  type    = string
  default = "EJB_vpc"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "private_EJB_subnets" {
  default = {
    "private_EJB_subnet_1" = 1
    "private_EJB_subnet_2" = 2
    "private_EJB_subnet_3" = 3
  }
}

variable "public_EJB_subnets" {
  default = {
    "public_EJB_subnet_1" = 1
    "public_EJB_subnet_2" = 2
    "public_EJB_subnet_3" = 3
  }
}

variable "variables_sub_cidr" {
  description = "CIDR Block for the Variables Subnet"
  type        = string
  default     = "10.0.202.0/24"
}

variable "variables_sub_az" {
  description = "Availability Zone used for Variables Subnet"
  type        = string
  default     = "us-east-1a"
}

variable "variables_sub_auto_ip" {
  description = "Set Automatic IP Assigment for Variables Subnet"
  type        = bool
  default     = true
}

variable "environment" {
  description = "Environment for Deployment"
  type        = string
  default     = true
}

variable "ssh_user" {
  default = "ubuntu"
}

# variable "root_password" {
#   default = "x"
# }
