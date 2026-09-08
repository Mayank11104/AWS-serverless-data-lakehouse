variable "project_name" {
  type        = string
  description = "The name of the project, used for resource naming"
  default     = "enterprise-dataops"
}

variable "environment" {
  type        = string
  description = "The environment deployment"
  default     = "dev"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the isolated VPC"
  default     = "10.0.0.0/16"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for the data generator"
  default     = "t3.small"
}
