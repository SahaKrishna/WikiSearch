

module "security" {
  source = "./security"

  vpc_main_id = var.vpc_id
  name        = var.name
  app_port    = var.app_port

  providers = {
    aws = aws
  }
}

module "logs" {
  source = "./logs"
  name = var.name
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name        = "ecs_execution_db"
  description = "ECS Execution Role"
  assume_role_policy = file("${path.module}/assume_role.json")
}

resource "aws_iam_role_policy_attachment" "role-attach" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


module "fargate_task" {
  source = "./task"

  name             = var.name
  ecs_exe_role_arn = aws_iam_role.ecsTaskExecutionRole.arn
  app_image        = var.app_image
  db_endpoint      = var.rds_endpoint

  providers = {
    aws = aws
  }
}

# module "fargate_serice" {
#   source = "./service"

#   name                = var.name
#   ecs_cluster_id      = var.ecs_cluster_id
#   task_definition_arn = module.fargate_task.task_definition_arn
#   private_subnets     = var.public_subnets
#   ecs_sg              = module.security.ecs_sg

#   providers = {
#     aws = aws
#   }
# }
