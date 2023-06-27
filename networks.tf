#Deploy the private subnets
resource "aws_subnet" "EJB_private_subnets" {
  for_each          = var.EJB_private_subnets
  vpc_id            = aws_vpc.EJB_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.value)
  availability_zone = tolist(data.aws_availability_zones.available.names)[each.value]
  tags = {
    Name        = each.key
    Terraform   = "true"
    project_tag = local.project_tag
  }
}

#Deploy the public subnets
resource "aws_subnet" "EJB_public_subnets" {
  for_each                = var.EJB_public_subnets
  vpc_id                  = aws_vpc.EJB_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, each.value + 100)
  availability_zone       = tolist(data.aws_availability_zones.available.names)[each.value]
  map_public_ip_on_launch = true
  tags = {
    Name        = each.key
    Terraform   = "true"
    project_tag = local.project_tag
  }
}

#Create route tables for public and private subnets 
resource "aws_route_table" "EJB_public_route_table" {
  vpc_id = aws_vpc.EJB_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.EJB_internet_gateway.id
    #nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name        = "EJB_public_rtb"
    Terraform   = "true"
    project_tag = local.project_tag
  }

}

resource "aws_route_table" "EJB_private_route_table" {
  vpc_id = aws_vpc.EJB_vpc.id
  count  = length(var.EJB_private_subnets)
  route {
    cidr_block = "0.0.0.0/0"
    # gateway_id     = aws_internet_gateway.internet_gateway.id

    nat_gateway_id = aws_nat_gateway.EJB_nat_gateway[count.index].id
  }
  tags = {
    Name        = "EJB_private_rtb"
    Terraform   = "true"
    project_tag = local.project_tag
  }
}

#Create route table associations
resource "aws_route_table_association" "EJB_rt_public" {
  depends_on     = [aws_subnet.EJB_public_subnets]
  route_table_id = aws_route_table.EJB_public_route_table.id
  for_each       = aws_subnet.EJB_public_subnets
  subnet_id      = each.value.id
}
resource "aws_route_table_association" "EJB_rt_private" {
  depends_on     = [aws_subnet.EJB_private_subnets]
  count          = length(var.EJB_private_subnets)
  route_table_id = aws_route_table.EJB_private_route_table[count.index].id
  subnet_id      = element(local.ec2_subnet_list_private, count.index)
}
#Create Internet Gateway
resource "aws_internet_gateway" "EJB_internet_gateway" {
  vpc_id = aws_vpc.EJB_vpc.id
  tags = {
    Name        = "EJB_igw"
    project_tag = local.project_tag
  }
}
#Create EIP for NAT Gateway
resource "aws_eip" "EJB_nat_gateway_eip" {
  vpc        = true
  count      = length(var.EJB_private_subnets)
  depends_on = [aws_internet_gateway.EJB_internet_gateway]
  tags = {
    Name        = "EJB_igw_eip"
    project_tag = local.project_tag
  }
}
#Create NAT Gateway
resource "aws_nat_gateway" "EJB_nat_gateway" {
  depends_on    = [aws_subnet.EJB_public_subnets]
  count         = length(var.EJB_private_subnets)
  allocation_id = aws_eip.EJB_nat_gateway_eip[count.index].id
  subnet_id     = element(local.ec2_subnet_list, count.index)
  tags = {
    Name        = "EJB_nat_gateway"
    project_tag = local.project_tag
  }
}

resource "aws_subnet" "EJB_variables-subnet" {
  vpc_id                  = aws_vpc.EJB_vpc.id
  cidr_block              = var.EJB_variables_sub_cidr
  availability_zone       = var.EJB_variables_sub_az
  map_public_ip_on_launch = var.EJB_variables_sub_auto_ip
  tags = {
    Name        = "EJB-sub-EJB_variables-${var.EJB_variables_sub_az}"
    Terraform   = "true"
    project_tag = local.project_tag
  }
}

resource "aws_db_subnet_group" "EJB_db_subnet_group" {
  name        = "ejb-db_subnet_group"
  description = "DB subnet group"
  subnet_ids  = [for subnet in aws_subnet.EJB_private_subnets : subnet.id]
}
