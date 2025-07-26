output "rds_db_name_secret_arn" {
  description = "RDS DB name secret ARN"
  value       = aws_secretsmanager_secret.rds_db_name.arn
}

output "rds_username_secret_arn" {
  description = "RDS username secret ARN"
  value       = aws_secretsmanager_secret.rds_username.arn
}

output "rds_password_secret_arn" {
  description = "RDS password secret ARN"
  value       = aws_secretsmanager_secret.rds_password.arn
}

output "rds_hostname_secret_arn" {
  description = "RDS hostname secret ARN"
  value       = aws_secretsmanager_secret.rds_hostname.arn
}

output "rds_port_secret_arn" {
  description = "RDS port secret ARN"
  value       = aws_secretsmanager_secret.rds_port.arn
}

output "s3_bucket_name_secret_arn" {
  description = "S3 bucket name secret ARN"
  value       = aws_secretsmanager_secret.s3_bucket_name.arn
}

output "s3_region_secret_arn" {
  description = "S3 region secret ARN"
  value       = aws_secretsmanager_secret.s3_region.arn
}

output "lb_endpoint_secret_arn" {
  description = "Load balancer endpoint secret ARN"
  value       = aws_secretsmanager_secret.lb_endpoint.arn
}

output "secret_arns" {
  description = "All secret ARNs"
  value = {
    rds_db_name   = aws_secretsmanager_secret.rds_db_name.arn
    rds_username  = aws_secretsmanager_secret.rds_username.arn
    rds_password  = aws_secretsmanager_secret.rds_password.arn
    rds_hostname  = aws_secretsmanager_secret.rds_hostname.arn
    rds_port      = aws_secretsmanager_secret.rds_port.arn
    s3_bucket_name = aws_secretsmanager_secret.s3_bucket_name.arn
    s3_region     = aws_secretsmanager_secret.s3_region.arn
    lb_endpoint   = aws_secretsmanager_secret.lb_endpoint.arn
  }
} 