terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key    = "rails-app/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# VPC and Networking
module "vpc" {
  source = "./modules/vpc"
  
  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr
  
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  
  availability_zones = var.availability_zones
}

# Secrets Manager
module "secrets" {
  source = "./modules/secrets"
  
  project_name = var.project_name
  environment  = var.environment
  
  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password
  db_endpoint = "placeholder" # Will be updated after RDS is created
  
  s3_bucket_name = "placeholder" # Will be updated after S3 is created
  s3_region      = var.aws_region
  
  lb_endpoint = "placeholder" # Will be updated after ALB is created
}

# RDS Database
module "rds" {
  source = "./modules/rds"
  
  project_name = var.project_name
  environment  = var.environment
  
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  ecs_security_group_id = "placeholder" # Will be updated after ECS is created
  
  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password
  db_instance_class = var.db_instance_class
}

# S3 Bucket
module "s3" {
  source = "./modules/s3"
  
  project_name = var.project_name
  environment  = var.environment
}

# ECS Cluster and Services
module "ecs" {
  source = "./modules/ecs"
  
  project_name = var.project_name
  environment  = var.environment
  
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  
  alb_security_group_id = "placeholder" # Will be updated after ALB is created
  
  s3_bucket_arn = module.s3.bucket_arn
  
  rds_db_name_secret_arn     = module.secrets.rds_db_name_secret_arn
  rds_username_secret_arn    = module.secrets.rds_username_secret_arn
  rds_password_secret_arn    = module.secrets.rds_password_secret_arn
  rds_hostname_secret_arn    = module.secrets.rds_hostname_secret_arn
  rds_port_secret_arn        = module.secrets.rds_port_secret_arn
  s3_bucket_name_secret_arn  = module.secrets.s3_bucket_name_secret_arn
  s3_region_secret_arn       = module.secrets.s3_region_secret_arn
  lb_endpoint_secret_arn     = module.secrets.lb_endpoint_secret_arn
}

# Application Load Balancer
module "alb" {
  source = "./modules/alb"
  
  project_name = var.project_name
  environment  = var.environment
  
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  
  target_group_arn = module.ecs.target_group_arn
}

# CodePipeline
module "codepipeline" {
  source = "./modules/codepipeline"
  
  project_name = var.project_name
  environment  = var.environment
  
  github_repository = var.github_repository
  github_branch     = var.github_branch
  
  codestar_connection_arn = var.codestar_connection_arn
  
  ecs_cluster_name = module.ecs.cluster_name
  ecs_service_name = module.ecs.service_name
  
  alb_listener_arn     = module.alb.listener_arn
  alb_target_group_name = "${var.project_name}-${var.environment}-tg"
}

# Secrets Manager
module "secrets" {
  source = "./modules/secrets"
  
  project_name = var.project_name
  environment  = var.environment
  
  db_endpoint = module.rds.db_endpoint
  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password
  
  s3_bucket_name = module.s3.bucket_name
  s3_region      = var.aws_region
  
  lb_endpoint = module.alb.dns_name
}

# Update secrets with actual values after infrastructure is created
resource "null_resource" "update_secrets" {
  depends_on = [
    module.rds,
    module.s3,
    module.alb,
    module.secrets
  ]

  provisioner "local-exec" {
    command = <<-EOT
      aws secretsmanager update-secret --secret-id "${module.secrets.rds_hostname_secret_arn}" --secret-string "${module.rds.db_endpoint}"
      aws secretsmanager update-secret --secret-id "${module.secrets.s3_bucket_name_secret_arn}" --secret-string "${module.s3.bucket_name}"
      aws secretsmanager update-secret --secret-id "${module.secrets.lb_endpoint_secret_arn}" --secret-string "${module.alb.dns_name}"
    EOT
  }
} 