# Fargate module

resource "aws_ecs_cluster" "main" {
  name = "${var.name}-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

module "fargate_app" {
  source = "../fargate_app"

  name        = var.name
  environment = var.environment
  aws_region  = var.aws_region

  vpc_id          = module.network.vpc_id
  public_subnets  = module.network.public_subnets
  private_subnets = module.network.private_subnets
  ecs_cluster_id  = aws_ecs_cluster.main.id

  app_image    = aws_ecr_repository.ecr.repository_url
  rds_endpoint = module.rds.rds_endpoint

  providers = {
    aws = aws
  }
}


module "fargate_dbimport" {
  source = "../fargate_dbimport"

  name        = "dbimport"
  environment = var.environment
  aws_region  = var.aws_region

  vpc_id          = module.network.vpc_id
  public_subnets  = module.network.public_subnets
  private_subnets = module.network.private_subnets
  ecs_cluster_id  = aws_ecs_cluster.main.id

  app_image    = aws_ecr_repository.ecr_db.repository_url
  rds_endpoint = module.rds.rds_endpoint
  providers = {
    aws = aws
  }
}
