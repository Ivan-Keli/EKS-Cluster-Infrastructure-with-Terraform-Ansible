# terraform/environments/dev/backend.tf
# Purpose: Backend configuration for storing Terraform state

# Configure S3 backend for state storage
# Uncomment and configure after creating S3 bucket and DynamoDB table
/*
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket-name"
    key            = "dev/eks-cluster/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
*/

# For now, using local backend
# Remove this when switching to S3 backend
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
