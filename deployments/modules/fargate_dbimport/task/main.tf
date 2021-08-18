data "aws_region" "current" {}

data "aws_caller_identity" "with" {}

locals {
  container_vars = {
    name = var.name,
    app_image = var.app_image,
    fargate_cpu = var.fargate_cpu,
    fargate_memory = var.fargate_memory,
    app_port = var.app_port,
    region_name = data.aws_region.current.name
    database = split( ":", var.db_endpoint)[0]
  }
}

resource "aws_ecs_task_definition" "main" {
  family                   = var.name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  execution_role_arn       = var.ecs_exe_role_arn
  container_definitions    = templatefile("${path.module}/container.json", local.container_vars)
}

