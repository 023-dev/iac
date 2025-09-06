resource "aws_db_subnet_group" "target_v2" {
  provider = aws.target
  name        = "${var.project_name}-target-db-subnet-group-v2"
  subnet_ids  = [
    aws_subnet.target_private_a.id,
    aws_subnet.target_private_b.id
  ]
  tags = { Name = "${var.project_name}-target-db-subnet-group-v2" }

  lifecycle { create_before_destroy = true }
}

resource "aws_db_instance" "target" {
  provider = aws.target

  identifier         = var.tgt_db_identifier
  instance_class     = "db.t3.medium"
  engine             = "mysql"
  engine_version     = "8.0"
  allocated_storage  = 20

  db_name            = var.tgt_db_name
  username           = var.tgt_db_username
  password           = var.tgt_db_new_password

  db_subnet_group_name   = aws_db_subnet_group.target_v2.name
  vpc_security_group_ids = [aws_security_group.target_rds.id]

  publicly_accessible = false
  skip_final_snapshot = true
  deletion_protection = false
  tags = { Name = var.tgt_db_identifier }
}
