# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "default-${replace(var.vpc_id, "vpc-", "")}"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-rds"

  # Engine
  engine         = "mysql"
  engine_version = "8.0.40"
  instance_class = "db.t4g.micro"

  # Storage
  allocated_storage     = 20
  max_allocated_storage = 1000
  storage_type          = "gp2"
  storage_encrypted     = true

  # Database
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  # Network
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = var.security_group_ids
  publicly_accessible    = false
  port                   = 3306

  # Backup
  backup_retention_period = 1
  backup_window          = "15:38-16:08"
  maintenance_window     = "sun:18:52-sun:19:22"

  # Monitoring
  monitoring_interval = 0
  
  # Options
  auto_minor_version_upgrade = true
  copy_tags_to_snapshot     = true
  deletion_protection       = false
  skip_final_snapshot      = true

  # Parameter Group
  parameter_group_name = "default.mysql8.0"
  option_group_name    = "default:mysql-8-0"

  tags = {
    Name = "${var.project_name}-rds"
  }
}
