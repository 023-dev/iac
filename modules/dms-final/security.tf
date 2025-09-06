resource "aws_security_group" "dms" {
  provider    = aws.target
  name        = "${var.project_name}-dms-sg"
  description = "Security group for DMS replication instance"
  vpc_id      = aws_vpc.target_new.id
  tags        = { Name = "${var.project_name}-dms-sg" }
}

resource "aws_security_group" "target_rds" {
  provider    = aws.target
  name        = "${var.project_name}-target-rds-sg"
  description = "Security group for new target RDS instance"
  vpc_id      = aws_vpc.target_new.id
  tags        = { Name = "${var.project_name}-target-rds-sg" }
}