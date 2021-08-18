output ecs_sg {
  value = module.security.ecs_sg
}

output ecs_execution_role {
  value = aws_iam_role.ecsTaskExecutionRole.arn
}
