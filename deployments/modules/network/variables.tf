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
