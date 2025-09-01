resource "aws_dms_endpoint" "source" {
  endpoint_id = "${var.project_name}-src"
  endpoint_type = "source"
  engine_name = "mysql"
  username = var.src_db_username
  password = var.src_db_password
  server_name = var.src_db_endpoint
  port = 3306
  database_name = var.src_db_name
}

resource "aws_dms_endpoint" "target" {
  endpoint_id = "${var.project_name}-tgt"
  endpoint_type = "target"
  engine_name = "mysql"
  username = var.tgt_db_username
  password = var.tgt_db_password
  server_name = var.tgt_db_endpoint
  port = 3306
  database_name = var.tgt_db_name
}
