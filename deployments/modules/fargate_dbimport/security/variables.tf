variable "app_port" {
  default     = "8080"
  type        = string
  description = "Application Port"
}


variable "vpc_main_id" {
  type        = string
  description = "VPC id"
}

variable "name" {
  type        = string
  description = "App name"
}
