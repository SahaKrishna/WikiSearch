# Traffic to the Database should come from ECS tasks only
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.name}-ecs-db"
  description = "allow outbound access"
  vpc_id      = var.vpc_main_id

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
