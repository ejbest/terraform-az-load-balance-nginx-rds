//private key **********************************/
resource "tls_private_key" "EJB_generated" {
  algorithm = "RSA"
}

resource "local_file" "EJB_private_key_pem" {
  content  = tls_private_key.EJB_generated.private_key_pem
  filename = "MyAWSKey.pem"
}

//publickey *************************************/
resource "aws_key_pair" "EJB_generated" {
  key_name   = "MyAWSKey"
  public_key = tls_private_key.EJB_generated.public_key_openssh

  lifecycle {
    ignore_changes = [key_name]
  }
}

# Security Groups
#resource "aws_security_group" "EJB-web-app" {
#  name   = "EJB-web-app-sg"
#  vpc_id = aws_vpc.EJB_vpc.id
#  tags = {
#    Name = "EJB-sg"
#  }
#}

resource "aws_security_group" "EJB-ec2" {
  name   = "EJB-ec2-sg"
  vpc_id = aws_vpc.EJB_vpc.id
  tags = {
    Name = "EJB-ec2-sg"
  }
}

resource "aws_security_group" "EJB-lb" {
  name   = "EJB-lb-sg"
  vpc_id = aws_vpc.EJB_vpc.id
  tags = {
    Name = "EJB-lb-sg"
  }
}

#resource "aws_security_group_rule" "EJB-ingress-ssh" {
#  from_port         = 22
#  protocol          = "tcp"
#  security_group_id = aws_security_group.EJB-web-app.id
#  to_port           = 22
#  type              = "ingress"
#  cidr_blocks       = ["108.5.148.208/32"]
#}

resource "aws_security_group_rule" "EJB-ingress-web-ec2" {
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.EJB-ec2.id
  to_port                  = 443
  type                     = "ingress"
  source_security_group_id = aws_security_group.EJB-lb.id
}

resource "aws_security_group_rule" "EJB-ingress-web-lb" {
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.EJB-lb.id
  to_port           = 443
  type              = "ingress"
  cidr_blocks       = ["108.5.148.208/32"]
}

#resource "aws_security_group_rule" "EJB-ingress-icmp" {
#  from_port         = -1
#  protocol          = "icmp"
#  security_group_id = aws_security_group.EJB-web-app.id
#  to_port           = -1
#  type              = "ingress"
#  cidr_blocks       = ["108.5.148.208/32"]
#}

resource "aws_security_group_rule" "EJB-ingress-self-ec2" {
  from_port         = -1
  protocol          = "-1"
  security_group_id = aws_security_group.EJB-ec2.id
  to_port           = -1
  type              = "ingress"
  self              = true
}

resource "aws_security_group_rule" "EJB-ingress-self-lb" {
  from_port         = -1
  protocol          = "-1"
  security_group_id = aws_security_group.EJB-lb.id
  to_port           = -1
  type              = "ingress"
  self              = true
}

resource "aws_security_group_rule" "EJB-egress-ec2" {
  from_port         = -1
  protocol          = "-1"
  security_group_id = aws_security_group.EJB-ec2.id
  to_port           = -1
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "EJB-egress-lb" {
  from_port         = -1
  protocol          = "-1"
  security_group_id = aws_security_group.EJB-lb.id
  to_port           = -1
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}


resource "aws_security_group" "EJB_db_sg" {
  name        = "EJB-db-sg"
  description = "Security group for databases"
  vpc_id      = aws_vpc.EJB_vpc.id

  ingress {
    description     = "Allow MySQL traffic from only the web sg"
    from_port       = "3306"
    to_port         = "3306"
    protocol        = "tcp"
    security_groups = [aws_security_group.EJB-ec2.id]
  }

  tags = {
    Name = "EJB-db-sg"
  }
}

resource "aws_network_acl" "EJB-acl" {
  vpc_id     = aws_vpc.EJB_vpc.id
  subnet_ids = local.ec2_subnet_list_private
  tags = {
    Name = "EJB-acl"
  }
}

resource "aws_network_acl_rule" "EJB-acl-443-allow" {
  network_acl_id = aws_network_acl.EJB-acl.id
  rule_number    = 100 + each.value
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  for_each       = var.EJB_public_subnets
  cidr_block     = cidrsubnet(var.vpc_cidr, 8, each.value + 100)
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "EJB-acl-443-deny" {
  network_acl_id = aws_network_acl.EJB-acl.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "deny"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "EJB-acl-ingress" {
  network_acl_id = aws_network_acl.EJB-acl.id
  rule_number    = 200
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = -1
  to_port        = -1
}

resource "aws_network_acl_rule" "EJB-acl-egress" {
  network_acl_id = aws_network_acl.EJB-acl.id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = -1
  to_port        = -1
}
