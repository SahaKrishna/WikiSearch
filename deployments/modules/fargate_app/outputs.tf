output lb_sg {
  value = module.security.lb_sg
}

output ecs_sg {
  value = module.security.ecs_sg
}

output target_group {
  value = module.alb.target_group
}

output ecs_execution_role {
  value = aws_iam_role.ecsTaskExecutionRole.arn
}
