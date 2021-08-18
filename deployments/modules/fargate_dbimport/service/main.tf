resource "aws_ecs_service" "main" {
  name            = "dbimport"
  cluster         = var.ecs_cluster_id
  task_definition = var.task_definition_arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [var.ecs_sg]
    subnets          = var.private_subnets
    assign_public_ip = true
  }

}
