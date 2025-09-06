resource "aws_dms_replication_task" "this" {
  replication_task_id       = "${var.project_name}-dms-task"
  migration_type            = "full-load"

  replication_instance_arn  = aws_dms_replication_instance.this.replication_instance_arn

  source_endpoint_arn       = aws_dms_endpoint.source.endpoint_arn
  target_endpoint_arn       = aws_dms_endpoint.target.endpoint_arn
  table_mappings            = file("${path.module}/table-mapping.json")
  replication_task_settings = file("${path.module}/task-settings.json")

  start_replication_task = false

  tags = {
    Name = "${var.project_name}-dms-task"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      replication_task_settings,
      start_replication_task
      # status,
    ]
  }
}