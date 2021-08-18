variable "vpc_main_id" {
  type        = string
  description = "VPC id"
}

variable "public_subnets" {
  type        = list
  description = "Public Subnets"
}

variable "security_group" {
  type        = string
  description = "LB Security group"
}

variable "name" {
  type        = string
  description = "Name"
}
