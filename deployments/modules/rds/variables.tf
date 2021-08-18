

variable "name" {
  type = string
}

variable "environment" {
  type = string
}

variable "rds_storage" {
  type    = string
  default = "100"
}

variable "rds_subnet_ids" {
  type = list
}

variable "rds_security_groups" {
  type        = list
  description = "Security groups for DB"
}

variable "rds_type" {
  type    = string
  default = "db.t3.medium"
}

variable "rds_engine_version" {
  type    = string
  default = "5.7"
}

variable "rds_instance_memory_mb" {
  type    = string
  default = "3700"
}

variable "rds_username" {
  type    = string
  default = "awsuser"
}

variable "rds_admin_pw" {
  type = string
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}
