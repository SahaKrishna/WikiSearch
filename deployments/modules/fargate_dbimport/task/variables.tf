variable "app_port" {
  default     = "8080"
  type        = string
  description = "Application Port"
}

variable "app_image" {
  type        = string
  description = "Application Container"
}

# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#task_size
variable "fargate_cpu" {
  default     = "256"
  type        = string
  description = "Fargate CPU"
}

variable "fargate_memory" {
  default     = "512"
  type        = string
  description = "Fargate Memory"
}

variable "name" {
  type        = string
  description = "Name"
}

variable "db_endpoint" {
  type        = string
  description = "Database endpoint"
}

variable "ecs_exe_role_arn" {
  type        = string
  description = "ECS Execution Role ARN"
}
