#!/bin/bash
# scripts/setup/setup-backend.sh
# Purpose: Script to set up Terraform backend infrastructure

set -e

echo "================================================"
echo "Setting up Terraform Backend Infrastructure"
echo "================================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
BACKEND_DIR="terraform/backend-setup"
ENV_DIR="terraform/environments/dev"

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install Terraform first."
        exit 1
    fi
    
    if ! command -v aws &> /dev/null; then
        print_error "AWS CLI is not installed. Please install AWS CLI first."
        exit 1
    fi
    
    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS credentials are not configured. Please run 'aws configure' first."
        exit 1
    fi
    
    print_status "Prerequisites check passed!"
}

# Create terraform.tfvars if it doesn't exist
setup_tfvars() {
    print_status "Setting up terraform.tfvars..."
    
    if [ ! -f "$BACKEND_DIR/terraform.tfvars" ]; then
        cp "$BACKEND_DIR/terraform.tfvars.example" "$BACKEND_DIR/terraform.tfvars"
        print_warning "Created terraform.tfvars from example. Please review and update if needed."
        echo "Press Enter to continue..."
        read
    fi
}

# Initialize and apply backend infrastructure
create_backend() {
    print_status "Creating backend infrastructure..."
    
    cd "$BACKEND_DIR"
    
    # Initialize Terraform
    print_status "Initializing Terraform..."
    terraform init
    
    # Plan
    print_status "Planning backend infrastructure..."
    terraform plan -out=backend.tfplan
    
    # Ask for confirmation
    echo -e "${YELLOW}Do you want to create the backend infrastructure? (yes/no)${NC}"
    read -r response
    
    if [[ "$response" == "yes" ]]; then
        print_status "Creating backend infrastructure..."
        terraform apply backend.tfplan
        
        # Save outputs
        print_status "Saving backend configuration..."
        terraform output -raw backend_config > backend-config.txt
        
        print_status "Backend infrastructure created successfully!"
        
        # Get account ID and bucket name
        ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
        BUCKET_NAME=$(terraform output -raw s3_bucket_name)
        TABLE_NAME=$(terraform output -raw dynamodb_table_name)
        
        echo ""
        echo "================================================"
        echo "Backend Infrastructure Created Successfully!"
        echo "================================================"
        echo "S3 Bucket: $BUCKET_NAME"
        echo "DynamoDB Table: $TABLE_NAME"
        echo ""
        echo "Next steps:"
        echo "1. Update terraform/environments/dev/backend.tf with:"
        cat backend-config.txt
        echo ""
        echo "2. Run 'terraform init -migrate-state' in terraform/environments/dev/"
        echo "================================================"
        
    else
        print_warning "Backend creation cancelled."
        exit 0
    fi
    
    cd - > /dev/null
}

# Main execution
main() {
    print_status "Starting Terraform backend setup..."
    
    check_prerequisites
    setup_tfvars
    create_backend
    
    print_status "Setup complete!"
}

# Run main function
main
