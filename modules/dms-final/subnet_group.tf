resource "aws_dms_replication_subnet_group" "target_v2" {
  provider = aws.target

  replication_subnet_group_id          = "${var.project_name}-dms-subnet-group-v2"
  replication_subnet_group_description = "DMS subnet group for ${var.project_name}"
  subnet_ids = [
    aws_subnet.target_private_a.id,
    aws_subnet.target_private_b.id
  ]
  tags = { Name = "${var.project_name}-dms-subnet-group-v2" }

  lifecycle { create_before_destroy = true }
}
