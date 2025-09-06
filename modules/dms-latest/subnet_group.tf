resource "aws_dms_replication_subnet_group" "this" {
  replication_subnet_group_id          = "${var.project_name}-dms-subnet-group"
  replication_subnet_group_description = "DMS subnet group for ${var.project_name}"
  subnet_ids                           = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-dms-subnet-group"
  }
}