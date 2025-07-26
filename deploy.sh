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

print_status "🚀 Starting Rails App Deployment..."

# Check if we're in the right directory
if [ ! -f "infrastructure/auto-deploy.sh" ]; then
    print_error "Please run this script from the project root directory"
    exit 1
fi

# Change to infrastructure directory and run auto-deploy
cd infrastructure
./auto-deploy.sh

if [ $? -eq 0 ]; then
    print_status "✅ Deployment completed successfully!"
    print_status "🎉 Your Rails application is now deployed on AWS!"
else
    print_error "❌ Deployment failed!"
    exit 1
fi 