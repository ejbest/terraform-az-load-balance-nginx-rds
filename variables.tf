variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_name" {
  type    = string
  default = "EJB_vpc"
}

variable "environment_name" {
  default     = "EJB"
  description = "The name of the environment"
}

# variable "environment" {
#   description = "Environment for Deployment"
#   type        = string
#   default     = true
# }

variable "EJB-rds_master_username" {
  default     = "rdsuser"
  description = "Enter RDS master username"
}

variable "EJB-aurora_database_name" {
  default     = "EJB-testrds"
  description = "Enter DB name"
}


variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "EJB_private_subnets" {
  default = {
    "EJB_private_subnet_1" = 1
    "EJB_private_subnet_2" = 2
    "EJB_private_subnet_3" = 3
  }
}

variable "EJB_public_subnets" {
  default = {
    "EJB_public_subnet_1" = 1
    "EJB_public_subnet_2" = 2
    "EJB_public_subnet_3" = 3
  }
}

variable "EJB_variables_sub_cidr" {
  description = "CIDR Block for the EJB_variables Subnet"
  type        = string
  default     = "10.0.202.0/24"
}

variable "EJB_variables_sub_az" {
  description = "Availability Zone used for EJB_variables Subnet"
  type        = string
  default     = "us-east-1a"
}

variable "EJB_variables_sub_auto_ip" {
  description = "Set Automatic IP Assigment for EJB_variables Subnet"
  type        = bool
  default     = true
}

variable "ssh_user" {
  default = "ubuntu"
}

# variable "root_password" {
#   default = "x"
# }
