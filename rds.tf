# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.environment_id}-db-subnet-group"
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name        = "${var.environment_id}-db-subnet-group"
    Environment = var.environment_id
  }
}

# RDS PostgreSQL Database
resource "aws_db_instance" "postgres" {
  identifier             = "${var.environment_id}-db"
  instance_class         = var.db_instance_type
  allocated_storage      = var.db_allocated_storage
  engine                 = "postgres"
  engine_version         = "17.5"
  username               = var.db_username
  password               = var.db_password
  db_name                = var.db_name
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.database.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  storage_encrypted      = false

  tags = {
    Name        = "${var.environment_id}-postgres-db"
    Environment = var.environment_id
    Tier        = "database"
  }
}