# To do, call RDS module

module "rds" {
  source              = "../rds"

  name                = var.name
  environment         = var.environment

  vpc_id              = module.network.vpc_id
  rds_subnet_ids      = module.network.public_subnets
  rds_security_groups = concat([module.fargate_app.ecs_sg], [module.fargate_app.lb_sg], [module.fargate_dbimport.ecs_sg])
  rds_admin_pw        = "0v3rH3ardABOUT1234562"

}

