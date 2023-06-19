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
resource "aws_security_group" "EJB-web-app" {
  name   = "EJB-web-app-sg"
  vpc_id = aws_vpc.EJB_vpc.id
  tags = {
    Name = "EJB-sg"
  }
}

resource "aws_security_group_rule" "EJB-ingress-ssh" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.EJB-web-app.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["108.35.155.143/32"]
}

resource "aws_security_group_rule" "EJB-ingress-web" {
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.EJB-web-app.id
  to_port           = 443
  type              = "ingress"
  cidr_blocks       = ["108.35.155.143/32"]
}

resource "aws_security_group_rule" "EJB-ingress-icmp" {
  from_port         = -1
  protocol          = "icmp"
  security_group_id = aws_security_group.EJB-web-app.id
  to_port           = -1
  type              = "ingress"
  cidr_blocks       = ["108.35.155.143/32"]
}

resource "aws_security_group_rule" "EJB-ingress-self" {
  from_port         = -1
  protocol          = "-1"
  security_group_id = aws_security_group.EJB-web-app.id
  to_port           = -1
  type              = "ingress"
  self              = true
}

resource "aws_security_group_rule" "EJB-egress" {
  from_port         = -1
  protocol          = "-1"
  security_group_id = aws_security_group.EJB-web-app.id
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
    security_groups = [aws_security_group.EJB-web-app.id]
  }

  tags = {
    Name = "EJB-db-sg"
  }
}