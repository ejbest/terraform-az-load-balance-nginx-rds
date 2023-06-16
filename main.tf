// getting started 
#Retrieve the list of AZs in the current AWS region
data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

locals {
  team        = "EJB_dev"
  application = "EJB_api"
  server_name = "EJB-${var.environment}-api-${var.variables_sub_az}"
  project_tag = "EJB"
  ec2_subnet_list = [aws_subnet.public_EJB_subnets["public_EJB_subnet_1"].id, aws_subnet.public_EJB_subnets["public_EJB_subnet_2"].id, aws_subnet.public_EJB_subnets["public_EJB_subnet_3"].id]
}

#Define the VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name        = var.vpc_name
    Environment = "EJB_VPC_environment"
    Terraform   = "true"
    Region      = data.aws_region.current.name
    project_tag = local.project_tag
  }
}


# Terraform Data Block - Lookup Ubuntu 16.04
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

resource "aws_instance" "ubuntu_server" {
  count                       = 3
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = element(local.ec2_subnet_list, count.index)
  security_groups             = [aws_security_group.EJB-vpc-ping.id, aws_security_group.ingress-ssh.id, aws_security_group.EJB-vpc-web.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.generated.key_name
  user_data                   = data.template_file.user_data.rendered
  tags = {
    Name        = "EJB-ubuntu-server"
    Owner       = local.team
    App         = local.application
    project_tag = local.project_tag
  }

  lifecycle {
    ignore_changes = [security_groups]
  }

  provisioner "local-exec" {
    command = "chmod 600 ${local_file.private_key_pem.filename}"
  }

}
