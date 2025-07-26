variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs"
  type        = list(string)
}

variable "target_group_arn" {
  description = "Target group ARN"
  type        = string
}

variable "certificate_arn" {
  description = "SSL certificate ARN"
  type        = string
  default     = ""
} 