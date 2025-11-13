# terraform/backend-setup/outputs.tf
# Purpose: Output values for backend configuration

output "s3_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.terraform_state.arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  value       = aws_dynamodb_table.terraform_state_lock.name
}

output "kms_key_id" {
  description = "ID of the KMS key for encryption"
  value       = aws_kms_key.terraform_state.id
}

output "kms_key_arn" {
  description = "ARN of the KMS key"
  value       = aws_kms_key.terraform_state.arn
}

output "iam_policy_arn" {
  description = "ARN of the IAM policy for state access"
  value       = aws_iam_policy.terraform_state_access.arn
}

output "backend_config" {
  description = "Backend configuration for terraform/environments/dev/backend.tf"
  value = <<-EOT
    terraform {
      backend "s3" {
        bucket         = "${aws_s3_bucket.terraform_state.id}"
        key            = "dev/eks-cluster/terraform.tfstate"
        region         = "${var.region}"
        encrypt        = true
        kms_key_id     = "${aws_kms_key.terraform_state.id}"
        dynamodb_table = "${aws_dynamodb_table.terraform_state_lock.name}"
      }
    }
  EOT
}
