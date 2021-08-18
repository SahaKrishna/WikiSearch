variable "name" {
  default     = "dbimport"
  type        = string
  description = "Application name"
}


variable "environment" {
  description = "The Environment Name"
  type        = string
}

variable "aws_region" {
  description = "The AWS region to deploy to (e.g. us-east-1)"
  type        = string
}


variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "public_subnets" {
  type        = list
  description = "Public subnet ids"
}

variable "private_subnets" {
  type        = list
  description = "Private subnet ids"
}

variable "app_image" {
  type        = string
  description = "Repo url and tag for container for task"
}

variable "app_port" {
  default     = "8080"
  type        = string
  description = "Application Port"
}

variable "rds_endpoint" {
  type = string
}

variable "ecs_cluster_id" {
  type        = string
  description = "ECS Cluster id"
}
