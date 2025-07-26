#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install Terraform >= 1.0"
        exit 1
    fi
    
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install AWS CLI"
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials not configured. Please run 'aws configure'"
        exit 1
    fi
    
    print_status "Prerequisites check passed!"
}

# Check if terraform.tfvars exists
check_config() {
    if [ ! -f "terraform.tfvars" ]; then
        print_error "terraform.tfvars file not found!"
        print_status "Please copy terraform.tfvars.example to terraform.tfvars and update the values"
        exit 1
    fi
    
    print_status "Configuration file found!"
}

# Initialize Terraform
init_terraform() {
    print_status "Initializing Terraform..."
    terraform init
    if [ $? -eq 0 ]; then
        print_status "Terraform initialized successfully!"
    else
        print_error "Terraform initialization failed!"
        exit 1
    fi
}

# Plan Terraform deployment
plan_terraform() {
    print_status "Planning Terraform deployment..."
    terraform plan -out=tfplan
    if [ $? -eq 0 ]; then
        print_status "Terraform plan created successfully!"
    else
        print_error "Terraform plan failed!"
        exit 1
    fi
}

# Apply Terraform deployment
apply_terraform() {
    print_status "Applying Terraform deployment..."
    terraform apply tfplan
    if [ $? -eq 0 ]; then
        print_status "Terraform deployment completed successfully!"
    else
        print_error "Terraform deployment failed!"
        exit 1
    fi
}

# Show outputs
show_outputs() {
    print_status "Infrastructure outputs:"
    terraform output
}

# Main deployment function
deploy() {
    print_status "Starting infrastructure deployment..."
    
    check_prerequisites
    check_config
    init_terraform
    plan_terraform
    
    echo
    print_warning "Review the plan above. Do you want to proceed with the deployment? (y/N)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        apply_terraform
        show_outputs
        print_status "Deployment completed! Check the outputs above for important information."
    else
        print_status "Deployment cancelled by user."
        exit 0
    fi
}

# Destroy infrastructure
destroy() {
    print_warning "This will destroy all infrastructure including the database and S3 bucket contents!"
    echo
    print_warning "Are you sure you want to proceed? (y/N)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        print_status "Destroying infrastructure..."
        terraform destroy -auto-approve
        if [ $? -eq 0 ]; then
            print_status "Infrastructure destroyed successfully!"
        else
            print_error "Infrastructure destruction failed!"
            exit 1
        fi
    else
        print_status "Destruction cancelled by user."
        exit 0
    fi
}

# Show help
show_help() {
    echo "Usage: $0 [COMMAND]"
    echo
    echo "Commands:"
    echo "  deploy   - Deploy the infrastructure"
    echo "  destroy  - Destroy the infrastructure"
    echo "  plan     - Show Terraform plan"
    echo "  init     - Initialize Terraform"
    echo "  help     - Show this help message"
    echo
    echo "Examples:"
    echo "  $0 deploy   # Deploy infrastructure"
    echo "  $0 destroy  # Destroy infrastructure"
    echo "  $0 plan     # Show deployment plan"
}

# Main script logic
case "$1" in
    deploy)
        deploy
        ;;
    destroy)
        destroy
        ;;
    plan)
        check_prerequisites
        check_config
        init_terraform
        terraform plan
        ;;
    init)
        check_prerequisites
        init_terraform
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        echo
        show_help
        exit 1
        ;;
esac 