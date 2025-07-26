# RDS Database Name Secret
resource "aws_secretsmanager_secret" "rds_db_name" {
  name = "${var.project_name}-${var.environment}-rds-db-name"

  tags = {
    Name = "${var.project_name}-${var.environment}-rds-db-name"
  }
}

resource "aws_secretsmanager_secret_version" "rds_db_name" {
  secret_id     = aws_secretsmanager_secret.rds_db_name.id
  secret_string = var.db_name
}

# RDS Username Secret
resource "aws_secretsmanager_secret" "rds_username" {
  name = "${var.project_name}-${var.environment}-rds-username"

  tags = {
    Name = "${var.project_name}-${var.environment}-rds-username"
  }
}

resource "aws_secretsmanager_secret_version" "rds_username" {
  secret_id     = aws_secretsmanager_secret.rds_username.id
  secret_string = var.db_username
}

# RDS Password Secret
resource "aws_secretsmanager_secret" "rds_password" {
  name = "${var.project_name}-${var.environment}-rds-password"

  tags = {
    Name = "${var.project_name}-${var.environment}-rds-password"
  }
}

resource "aws_secretsmanager_secret_version" "rds_password" {
  secret_id     = aws_secretsmanager_secret.rds_password.id
  secret_string = var.db_password
}

# RDS Hostname Secret
resource "aws_secretsmanager_secret" "rds_hostname" {
  name = "${var.project_name}-${var.environment}-rds-hostname"

  tags = {
    Name = "${var.project_name}-${var.environment}-rds-hostname"
  }
}

resource "aws_secretsmanager_secret_version" "rds_hostname" {
  secret_id     = aws_secretsmanager_secret.rds_hostname.id
  secret_string = var.db_endpoint
}

# RDS Port Secret
resource "aws_secretsmanager_secret" "rds_port" {
  name = "${var.project_name}-${var.environment}-rds-port"

  tags = {
    Name = "${var.project_name}-${var.environment}-rds-port"
  }
}

resource "aws_secretsmanager_secret_version" "rds_port" {
  secret_id     = aws_secretsmanager_secret.rds_port.id
  secret_string = "5432"
}

# S3 Bucket Name Secret
resource "aws_secretsmanager_secret" "s3_bucket_name" {
  name = "${var.project_name}-${var.environment}-s3-bucket-name"

  tags = {
    Name = "${var.project_name}-${var.environment}-s3-bucket-name"
  }
}

resource "aws_secretsmanager_secret_version" "s3_bucket_name" {
  secret_id     = aws_secretsmanager_secret.s3_bucket_name.id
  secret_string = var.s3_bucket_name
}

# S3 Region Secret
resource "aws_secretsmanager_secret" "s3_region" {
  name = "${var.project_name}-${var.environment}-s3-region"

  tags = {
    Name = "${var.project_name}-${var.environment}-s3-region"
  }
}

resource "aws_secretsmanager_secret_version" "s3_region" {
  secret_id     = aws_secretsmanager_secret.s3_region.id
  secret_string = var.s3_region
}

# Load Balancer Endpoint Secret
resource "aws_secretsmanager_secret" "lb_endpoint" {
  name = "${var.project_name}-${var.environment}-lb-endpoint"

  tags = {
    Name = "${var.project_name}-${var.environment}-lb-endpoint"
  }
}

resource "aws_secretsmanager_secret_version" "lb_endpoint" {
  secret_id     = aws_secretsmanager_secret.lb_endpoint.id
  secret_string = var.lb_endpoint
} 