resource "aws_db_subnet_group" "wordpress" {
  name       = "wordpress-rds-subnet"
  subnet_ids =  [aws_subnet.private_subnet1.id , aws_subnet.private_subnet2.id, aws_subnet.public_subnet1.id]

}
resource "aws_security_group" "wordpress_database" {
  
name        = "wordpress-database-sg"
  description = "Allow http traffic from instance"
  vpc_id      = aws_vpc.wp_vpc.id
tags = {
    "Name" : "wordpress-database-sg"
 
  }
}
resource "aws_security_group_rule" "wordpress-database-from-instance" {
  
description = "Accept traffic from instance security group"
type      = "ingress"
  from_port = 3306
  to_port   = 3306
  protocol  = "tcp"
security_group_id        = aws_security_group.wordpress_database.id
  source_security_group_id = aws_security_group.wordpress_instance.id
}

resource "aws_db_instance" "DataBase" {
  allocated_storage    = 20
  max_allocated_storage = 100
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7.22"
  instance_class       = "db.t2.micro"
  name                 = var.dbname
  username             = var.dbuser
  password             = var.dbpass
  parameter_group_name = "default.mysql5.7"
  publicly_accessible = false
  db_subnet_group_name = aws_db_subnet_group.wordpress.name
  availability_zone = var.availability_zone1
  vpc_security_group_ids = [aws_security_group.wordpress_database.id]

  skip_final_snapshot = true 
  provisioner "local-exec" {
  command = "echo db_host: ${aws_db_instance.DataBase.endpoint} >> craft2/vars/main.yml "
    }
}

