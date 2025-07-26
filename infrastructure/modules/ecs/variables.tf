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

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "ALB security group ID"
  type        = string
}



variable "s3_bucket_arn" {
  description = "S3 bucket ARN"
  type        = string
}

variable "rds_db_name_secret_arn" {
  description = "RDS DB name secret ARN"
  type        = string
}

variable "rds_username_secret_arn" {
  description = "RDS username secret ARN"
  type        = string
}

variable "rds_password_secret_arn" {
  description = "RDS password secret ARN"
  type        = string
}

variable "rds_hostname_secret_arn" {
  description = "RDS hostname secret ARN"
  type        = string
}

variable "rds_port_secret_arn" {
  description = "RDS port secret ARN"
  type        = string
}

variable "s3_bucket_name_secret_arn" {
  description = "S3 bucket name secret ARN"
  type        = string
}

variable "s3_region_secret_arn" {
  description = "S3 region secret ARN"
  type        = string
}

variable "lb_endpoint_secret_arn" {
  description = "Load balancer endpoint secret ARN"
  type        = string
} 