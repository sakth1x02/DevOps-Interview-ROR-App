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

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null; then
    print_error "AWS CLI not configured. Please run 'aws configure' first."
    exit 1
fi

print_status "Starting automated deployment..."

# Run setup script
print_status "Running setup script..."
./setup.sh

if [ $? -ne 0 ]; then
    print_error "Setup failed!"
    exit 1
fi

# Check if CodeStar connection is available
print_status "Checking CodeStar connection status..."
CONNECTION_ARN=$(grep "codestar_connection_arn" terraform.tfvars | cut -d'"' -f2)
CONNECTION_STATUS=$(aws codestar-connections get-connection --connection-arn "$CONNECTION_ARN" --query "ConnectionStatus" --output text 2>/dev/null)

if [ "$CONNECTION_STATUS" != "AVAILABLE" ]; then
    print_warning "CodeStar connection is not available yet."
    print_warning "Please complete the GitHub authorization in the AWS Console:"
    print_warning "1. Go to AWS CodeStar console"
    print_warning "2. Find the connection with ARN: $CONNECTION_ARN"
    print_warning "3. Click 'Pending' and complete the GitHub authorization"
    print_warning "4. Wait for the connection to become 'Available'"
    print_warning "5. Then run this script again"
    exit 1
fi

print_status "CodeStar connection is available. Proceeding with deployment..."

# Initialize Terraform
print_status "Initializing Terraform..."
terraform init

if [ $? -ne 0 ]; then
    print_error "Terraform initialization failed!"
    exit 1
fi

# Apply Terraform
print_status "Applying Terraform configuration..."
terraform apply -auto-approve

if [ $? -ne 0 ]; then
    print_error "Terraform apply failed!"
    exit 1
fi

print_status "Deployment completed successfully!"
print_status "Your Rails application is now deployed!"

# Show outputs
print_status "Infrastructure outputs:"
terraform output

print_status "Next steps:"
print_status "1. Push your code to GitHub to trigger the pipeline"
print_status "2. Monitor the deployment in AWS CodePipeline console"
print_status "3. Access your application at the ALB URL shown above" 