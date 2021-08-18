variable "app_port" {
  default     = "8080"
  type        = string
  description = "Application Port"
}

variable "app_count" {
  default     = "1"
  type        = string
  description = "Container number"
}

variable "private_subnets" {
  type        = list
  description = "Private subnets"
}

variable "ecs_sg" {
  type        = string
  description = "ECS Security Group"
}

variable "alb_tg" {
  type        = string
  description = "Alb target group"
}

variable "name" {
  type        = string
  description = "Name"
}

variable "ecs_cluster_id" {
  type        = string
  description = "ECS Cluster id"
}

variable "task_definition_arn" {
  type        = string
  description = "ECS Task definition ARN"
}
