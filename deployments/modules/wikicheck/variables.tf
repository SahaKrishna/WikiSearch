variable "environment" {
  description = "The Environment Name"
  type        = string
}

variable "aws_region" {
  description = "The AWS region to deploy to (e.g. us-east-1)"
  type        = string
}

variable "role_arn" {
    description = "Role ARN for AWS account to operate in"
}

variable "az_count" {
  default     = 2
  type        = string
  description = "Number of AZ counts to use"
}

variable "cidr_block" {
  default     = "17.1.0.0/16"
  type        = string
  description = "Base CIDR"
}


variable "name" {
  default     = "wiki-check"
  type        = string
  description = "Wiki-check"
}

variable "app_port" {
  default     = "8080"
  type        = string
  description = "Application Port"
}
