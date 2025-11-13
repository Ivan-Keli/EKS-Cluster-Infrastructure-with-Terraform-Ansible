# terraform/environments/dev/backend.tf
# Purpose: Backend configuration for storing Terraform state

# IMPORTANT: Run terraform/backend-setup first to create these resources
# Then uncomment the s3 backend block below and comment out the local backend

# Configure S3 backend for state storage
# terraform {
#   backend "s3" {
#     bucket         = "eks-cluster-terraform-state-[ACCOUNT-ID]-dev"  # Replace [ACCOUNT-ID]
#     key            = "dev/eks-cluster/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     kms_key_id     = "alias/eks-cluster-terraform-state-dev"
#     dynamodb_table = "eks-cluster-terraform-state-lock-dev"
#   }
# }

# For initial setup, using local backend
# Comment this out after setting up S3 backend
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
