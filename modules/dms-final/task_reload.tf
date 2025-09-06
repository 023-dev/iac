resource "null_resource" "reload_existing_task" {
  triggers = {
    task_arn     = var.reuse_task_arn
    reload_token = var.reload_token
    kind         = "reload-target"
  }

  provisioner "local-exec" {
    command = "AWS_PROFILE=${var.target_aws_profile} AWS_REGION=${var.aws_region} aws dms start-replication-task --replication-task-arn ${var.reuse_task_arn} --start-replication-task-type reload-target"
  }
}
