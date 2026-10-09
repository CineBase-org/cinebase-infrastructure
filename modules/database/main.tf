terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.66.0"
    }
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.project-name}-db-subnet-group"
  subnet_ids = var.private_subnets_ids

  tags = {
    Name = "${var.project-name}-db-subnet-group"
  }
}

resource "aws_security_group" "db_security_group" {
  name        = "${var.project-name}-db-sg"
  description = "Security group for RDS database"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project-name}-db-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "db-sg-ingress" {
  security_group_id = aws_security_group.db_security_group.id

  referenced_security_group_id = var.ecs_ec2_sg_id
  from_port                    = 5432
  ip_protocol                  = "tcp"
  to_port                      = 5432
}

resource "aws_db_instance" "db_instance" {
  engine                  = "postgres"
  instance_class          = "db.t4g.micro"
  allocated_storage       = 20
  storage_type            = "gp3"
  multi_az                = false
  publicly_accessible     = false
  port                    = 5432
  storage_encrypted       = true
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.db_security_group.id]
  username                = "${var.project-name}_admin"
  password_wo             = var.db_password
  password_wo_version     = 1
  identifier              = "${var.project-name}-postgres-db"
  db_name                 = "${var.project-name}_db"
  backup_retention_period = 7
  deletion_protection     = false
  skip_final_snapshot     = true
}