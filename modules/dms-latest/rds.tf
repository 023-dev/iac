# resource "aws_db_snapshot" "latest" {
#   provider = aws.source
#
#   db_instance_identifier = data.aws_db_instance.source.id
#   db_snapshot_identifier = "${data.aws_db_instance.source.id}-snapshot-${formatdate("YYYYMMDD", timestamp())}"
#
#   shared_accounts = [var.target_aws_account_id]
#
#   tags = {
#     Name = "${data.aws_db_instance.source.id}-snapshot-for-migration"
#   }
#
#   lifecycle {
#     ignore_changes = [db_snapshot_identifier]
#   }
# }
# 스냅샷 이용은 불가능함

resource "aws_db_subnet_group" "target" {
  name       = "${var.project_name}-target-db-subnet-group"
  subnet_ids = var.private_subnet_ids
  tags = {
    Name = "${var.project_name}-target-db-subnet-group"
  }
}

resource "aws_db_instance" "target" {
  identifier           = var.tgt_db_identifier
  instance_class       = "db.t3.medium"
  engine               = "mysql"
  engine_version       = "8.0"
  allocated_storage    = 20

  db_name              = var.tgt_db_name
  username             = var.tgt_db_username
  password             = var.tgt_db_new_password

  db_subnet_group_name   = aws_db_subnet_group.target.name
  vpc_security_group_ids = var.target_db_security_group_ids

  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name = var.tgt_db_identifier
  }
}