# Infrastructure as Code - Rails App Deployment

This directory contains the Terraform configuration for deploying a Rails application on AWS using ECS, RDS, S3, and CodePipeline.

## Architecture Overview

The infrastructure consists of:

- **VPC** with public and private subnets across 2 AZs
- **RDS PostgreSQL** database in private subnets
- **S3 Bucket** for file storage
- **ECS Fargate** cluster running Rails app and Nginx proxy
- **Application Load Balancer** for traffic distribution
- **CodePipeline** for CI/CD automation
- **Secrets Manager** for secure credential storage

## Prerequisites

1. **AWS CLI** configured with appropriate permissions
2. **Terraform** >= 1.0 installed
3. **GitHub repository** with the Rails application
4. **CodeStar Connection** for GitHub integration
5. **S3 bucket** for Terraform state (create manually)

## Setup Instructions

### 1. Create S3 Bucket for Terraform State

```bash
aws s3 mb s3://your-terraform-state-bucket
aws s3api put-bucket-versioning --bucket your-terraform-state-bucket --versioning-configuration Status=Enabled
```

### 2. Create CodeStar Connection

1. Go to AWS CodeStar console
2. Create a new connection to your GitHub repository
3. Note the connection ARN

### 3. Configure Variables

Create a `terraform.tfvars` file:

```hcl
aws_region = "us-east-1"
project_name = "rails-app"
environment = "production"
db_password = "your-secure-password"
github_repository = "your-username/DevOps-Interview-ROR-App"
github_branch = "main"
codestar_connection_arn = "arn:aws:codestar-connections:region:account:connection/connection-id"
```

### 4. Initialize and Deploy

```bash
cd infrastructure
terraform init
terraform plan
terraform apply
```

## Infrastructure Components

### VPC Module (`./modules/vpc`)
- Creates VPC with CIDR 10.0.0.0/16
- 2 public subnets (10.0.1.0/24, 10.0.2.0/24)
- 2 private subnets (10.0.3.0/24, 10.0.4.0/24)
- Internet Gateway and NAT Gateway
- Route tables for public and private subnets

### RDS Module (`./modules/rds`)
- PostgreSQL 13.3 instance
- Multi-AZ deployment
- Encrypted storage
- Security group allowing access from ECS

### S3 Module (`./modules/s3`)
- Encrypted bucket for file storage
- Versioning enabled
- Lifecycle policies for cleanup

### ECS Module (`./modules/ecs`)
- Fargate cluster with 2 tasks
- Rails app and Nginx proxy containers
- Auto-scaling based on CPU/memory
- CloudWatch logging
- IAM roles for S3 access

### ALB Module (`./modules/alb`)
- Application Load Balancer in public subnets
- HTTP (port 80) and HTTPS (port 443) listeners
- Health checks and target group

### CodePipeline Module (`./modules/codepipeline`)
- Source stage: GitHub integration
- Build stage: CodeBuild with buildspec.yml
- Deploy stage: CodeDeploy to ECS

### Secrets Module (`./modules/secrets`)
- Stores all sensitive configuration
- RDS credentials
- S3 configuration
- Load balancer endpoint

## Environment Variables

The Rails application expects these environment variables:

```env
RDS_DB_NAME=rails_production
RDS_USERNAME=postgres
RDS_PASSWORD=<from-secrets>
RDS_HOSTNAME=<from-secrets>
RDS_PORT=5432
S3_BUCKET_NAME=<from-secrets>
S3_REGION=<from-secrets>
LB_ENDPOINT=<from-secrets>
```

## Deployment Process

1. **Code Push**: Developer pushes to GitHub
2. **CodePipeline Trigger**: Automatically starts pipeline
3. **CodeBuild**: Builds Docker images and pushes to ECR
4. **CodeDeploy**: Deploys new task definition to ECS
5. **Health Check**: ALB verifies new deployment
6. **Traffic Switch**: ALB routes traffic to new containers

## Monitoring and Logging

- **CloudWatch Logs**: Application and container logs
- **CloudWatch Metrics**: ECS, RDS, and ALB metrics
- **ECS Service Events**: Deployment status and health

## Security Features

- All resources in private subnets (except ALB)
- Encrypted RDS storage
- Encrypted S3 bucket
- Secrets Manager for credentials
- IAM roles with least privilege
- Security groups with minimal access

## Scaling

- **ECS**: Auto-scaling based on CPU/memory
- **RDS**: Multi-AZ for high availability
- **ALB**: Distributes traffic across containers

## Cost Optimization

- Use t3.micro for RDS (upgrade as needed)
- Fargate spot instances for non-production
- S3 lifecycle policies for cost control
- CloudWatch log retention policies

## Troubleshooting

### Common Issues

1. **ECS Tasks Not Starting**
   - Check CloudWatch logs
   - Verify Secrets Manager permissions
   - Check security group rules

2. **Database Connection Issues**
   - Verify RDS security group allows ECS
   - Check Secrets Manager values
   - Verify VPC connectivity

3. **CodePipeline Failures**
   - Check CodeStar connection status
   - Verify buildspec.yml syntax
   - Check IAM permissions

### Useful Commands

```bash
# Check ECS service status
aws ecs describe-services --cluster rails-app-production-cluster --services rails-app-production-service

# View CloudWatch logs
aws logs describe-log-streams --log-group-name /ecs/rails-app

# Check ALB health
aws elbv2 describe-target-health --target-group-arn <target-group-arn>
```

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Warning**: This will delete all data including the RDS database and S3 bucket contents.

## Support

For issues or questions:
1. Check CloudWatch logs
2. Review Terraform plan output
3. Verify AWS service quotas
4. Check IAM permissions 