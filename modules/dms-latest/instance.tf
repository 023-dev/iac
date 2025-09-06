resource "aws_dms_replication_instance" "this" {
  replication_instance_id        = "${var.project_name}-dms-instance"
  replication_instance_class     = "dms.t3.medium"
  allocated_storage              = 50
  vpc_security_group_ids         = var.dms_security_group_ids
  replication_subnet_group_id    = aws_dms_replication_subnet_group.this.id
  multi_az                       = false
  publicly_accessible            = false
  apply_immediately              = true

  tags = {
    Name        = "${var.project_name}-dms-instance"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}