# resource "aws_dms_replication_task" "this" {
#   replication_task_id          = "${var.project_name}-dms-task"
#   migration_type               = "full-load"
#   replication_instance_arn     = aws_dms_replication_instance.this.replication_instance_arn
#   source_endpoint_arn          = aws_dms_endpoint.source.endpoint_arn
#   target_endpoint_arn          = aws_dms_endpoint.target.endpoint_arn
#   table_mappings               = file("${path.module}/table-mapping.json")
#   replication_task_settings    = file("${path.module}/task-settings.json")
#   start_replication_task       = true
#
#   tags = {
#     Name = "${var.project_name}-dms-task"
#   }
# }

resource "aws_dms_replication_task" "this" {
  replication_task_id       = "${var.project_name}-dms-task"
  migration_type            = "full-load"
  replication_instance_arn  = data.aws_dms_replication_instance.this.replication_instance_arn
  source_endpoint_arn       = aws_dms_endpoint.source.endpoint_arn
  target_endpoint_arn       = aws_dms_endpoint.target.endpoint_arn
  table_mappings            = file("${path.module}/table-mapping.json")
  replication_task_settings = file("${path.module}/task-settings.json")

  # 처음에는 수동으로 실행/정지 관리할 수 있게 false로
  start_replication_task = false

  tags = {
    Name = "${var.project_name}-dms-task"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      replication_task_settings, # DMS가 내부 기본값 채워 넣어 drift 잦음
      start_replication_task,    # 실행/정지 상태
      status,                    # 읽기 전용
    ]
  }
}
