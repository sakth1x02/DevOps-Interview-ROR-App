#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get current AWS account ID and region
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=$(aws configure get region)

print_status "AWS Account ID: $AWS_ACCOUNT_ID"
print_status "AWS Region: $AWS_REGION"

# Create S3 bucket for Terraform state if it doesn't exist
TERRAFORM_STATE_BUCKET="rails-app-terraform-state-${AWS_ACCOUNT_ID}"

print_status "Creating S3 bucket for Terraform state: $TERRAFORM_STATE_BUCKET"

if ! aws s3 ls "s3://$TERRAFORM_STATE_BUCKET" 2>&1 > /dev/null; then
    aws s3 mb "s3://$TERRAFORM_STATE_BUCKET" --region $AWS_REGION
    aws s3api put-bucket-versioning --bucket "$TERRAFORM_STATE_BUCKET" --versioning-configuration Status=Enabled
    aws s3api put-bucket-encryption --bucket "$TERRAFORM_STATE_BUCKET" --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }'
    print_status "S3 bucket created successfully"
else
    print_status "S3 bucket already exists"
fi

# Update the backend configuration in main.tf
print_status "Updating Terraform backend configuration..."
sed -i "s/your-terraform-state-bucket/$TERRAFORM_STATE_BUCKET/g" main.tf
sed -i "s/us-east-1/$AWS_REGION/g" main.tf

# Create ECR repositories
print_status "Creating ECR repositories..."

# Rails app repository
if ! aws ecr describe-repositories --repository-names rails-app --region $AWS_REGION 2>&1 > /dev/null; then
    aws ecr create-repository --repository-name rails-app --region $AWS_REGION
    print_status "ECR repository 'rails-app' created"
else
    print_status "ECR repository 'rails-app' already exists"
fi

# Nginx proxy repository
if ! aws ecr describe-repositories --repository-names nginx-proxy --region $AWS_REGION 2>&1 > /dev/null; then
    aws ecr create-repository --repository-name nginx-proxy --region $AWS_REGION
    print_status "ECR repository 'nginx-proxy' created"
else
    print_status "ECR repository 'nginx-proxy' already exists"
fi

# Create CodeStar connection for GitHub
print_status "Creating CodeStar connection for GitHub..."

# Check if connection already exists
EXISTING_CONNECTION=$(aws codestar-connections list-connections --query "Connections[?ConnectionStatus=='AVAILABLE'].ConnectionArn" --output text)

if [ -z "$EXISTING_CONNECTION" ]; then
    # Create new connection
    CONNECTION_ARN=$(aws codestar-connections create-connection \
        --provider-type GitHub \
        --name "rails-app-github-connection" \
        --query "ConnectionArn" \
        --output text)
    
    print_status "CodeStar connection created: $CONNECTION_ARN"
    print_warning "Please complete the connection in the AWS Console:"
    print_warning "1. Go to AWS CodeStar console"
    print_warning "2. Find the connection with ARN: $CONNECTION_ARN"
    print_warning "3. Click 'Pending' and complete the GitHub authorization"
    print_warning "4. Wait for the connection to become 'Available'"
    
    # Update terraform.tfvars with the new connection ARN
    sed -i "s|arn:aws:codestar-connections:us-east-1:123456789012:connection/your-connection-id|$CONNECTION_ARN|g" terraform.tfvars
else
    print_status "Using existing CodeStar connection: $EXISTING_CONNECTION"
    sed -i "s|arn:aws:codestar-connections:us-east-1:123456789012:connection/your-connection-id|$EXISTING_CONNECTION|g" terraform.tfvars
fi

# Update region in terraform.tfvars
sed -i "s/us-east-1/$AWS_REGION/g" terraform.tfvars

# Generate a secure database password
DB_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
sed -i "s/RailsApp2024!/$DB_PASSWORD/g" terraform.tfvars

print_status "Setup completed successfully!"
print_status "You can now run: terraform init && terraform apply" 