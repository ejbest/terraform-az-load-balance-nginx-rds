resource "random_password" "EJB-password" {
  length           = 16
  special          = true
  override_special = "!#$%&*=+"
}


resource "aws_db_instance" "EJB_database" {
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  username               = var.EJB-rds_master_username
  password               = random_password.EJB-password.result
  db_subnet_group_name   = aws_db_subnet_group.EJB_db_subnet_group.id
  vpc_security_group_ids = [aws_security_group.EJB_db_sg.id]
  skip_final_snapshot    = true
  parameter_group_name   = "default.mysql5.7"
}