// getting started 
#Retrieve the list of AZs in the current AWS region
data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

locals {
  team            = "EJB_dev"
  application     = "EJB_api"
  server_name     = "EJB-api-${var.EJB_variables_sub_az}"
  project_tag     = "EJB"
  ec2_subnet_list = [aws_subnet.EJB_public_subnets["EJB_public_subnet_1"].id, aws_subnet.EJB_public_subnets["EJB_public_subnet_2"].id, aws_subnet.EJB_public_subnets["EJB_public_subnet_3"].id]
}

#Define the VPC
resource "aws_vpc" "EJB_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name        = var.vpc_name
    Environment = "EJB_VPC_environment"
    Terraform   = "true"
    Region      = data.aws_region.current.name
    project_tag = local.project_tag
  }
}

# Terraform Data Block - Lookup Ubuntu 22.04
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-22.04-amd64-server-*"]
  }
  owners = ["099720109477"]
}

data "template_file" "user_data" {
  template = file("./cloud_init.cfg")
}

