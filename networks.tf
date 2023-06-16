#Deploy the private subnets
resource "aws_subnet" "private_EJB_subnets" {
  for_each          = var.private_EJB_subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.value)
  availability_zone = tolist(data.aws_availability_zones.available.names)[each.value]
  tags = {
    Name        = each.key
    Terraform   = "true"
    project_tag = local.project_tag
  }
}

#Deploy the public subnets
resource "aws_subnet" "public_EJB_subnets" {
  for_each                = var.public_EJB_subnets
  vpc_id                  = aws_vpc.vpc.id
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
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.EJB_internet_gateway.id
    #nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name        = "public_EJB_rtb"
    Terraform   = "true"
    project_tag = local.project_tag
  }

}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    # gateway_id     = aws_internet_gateway.internet_gateway.id

    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name        = "private_EJB_rtb"
    Terraform   = "true"
    project_tag = local.project_tag
  }
}

#Create route table associations
resource "aws_route_table_association" "public" {
  depends_on     = [aws_subnet.public_EJB_subnets]
  route_table_id = aws_route_table.public_route_table.id
  for_each       = aws_subnet.public_EJB_subnets
  subnet_id      = each.value.id
}
resource "aws_route_table_association" "private" {
  depends_on     = [aws_subnet.private_EJB_subnets]
  route_table_id = aws_route_table.private_route_table.id
  for_each       = aws_subnet.private_EJB_subnets
  subnet_id      = each.value.id
}
#Create Internet Gateway
resource "aws_internet_gateway" "EJB_internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "EJB_igw"
    project_tag = local.project_tag
  }
}
#Create EIP for NAT Gateway
resource "aws_eip" "nat_gateway_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.EJB_internet_gateway]
  tags = {
    Name        = "EJB_igw_eip"
    project_tag = local.project_tag
  }
}
#Create NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  depends_on    = [aws_subnet.public_EJB_subnets]
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_EJB_subnets["public_EJB_subnet_1"].id
  tags = {
    Name        = "EJB_nat_gateway"
    project_tag = local.project_tag
  }
}

resource "aws_subnet" "variables-subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.variables_sub_cidr
  availability_zone       = var.variables_sub_az
  map_public_ip_on_launch = var.variables_sub_auto_ip
  tags = {
    Name        = "EJB-sub-variables-${var.variables_sub_az}"
    Terraform   = "true"
    project_tag = local.project_tag
  }
}




// Web Here 
# Create Security Group - Web Traffic
resource "aws_security_group" "EJB-vpc-web" {
  name        = "EJB-vpc-web-${terraform.workspace}"
  vpc_id      = aws_vpc.vpc.id
  description = "Web Traffic"
  # ingress {
  #   description = "Allow Port 80"
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
  ingress {
    description = "Allow Port 443"
    from_port   = 80
    to_port     = 80

    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Allow all ip and ports outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "EJB-vpc-ping" {
  name        = "vpc-ping"
  vpc_id      = aws_vpc.vpc.id
  description = "ICMP for Ping Access"

  ingress {
    description = "Allow ICMP Traffic"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all ip and ports outboun"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


