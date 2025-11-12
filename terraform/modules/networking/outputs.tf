# terraform/modules/networking/outputs.tf
# Purpose: Output values from networking module

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = aws_nat_gateway.main.id
}

output "nat_gateway_public_ip" {
  description = "Public IP address of the NAT Gateway"
  value       = aws_eip.nat.public_ip
}

output "nat_security_group_id" {
  description = "ID of the NAT Gateway security group"
  value       = aws_security_group.nat.id
}

output "vpc_endpoints_security_group_id" {
  description = "ID of the VPC endpoints security group"
  value       = aws_security_group.vpc_endpoints.id
}

output "s3_endpoint_id" {
  description = "ID of the S3 VPC endpoint"
  value       = aws_vpc_endpoint.s3.id
}

output "ecr_api_endpoint_id" {
  description = "ID of the ECR API VPC endpoint"
  value       = var.enable_vpc_endpoints ? aws_vpc_endpoint.ecr_api.id : null
}

output "ecr_dkr_endpoint_id" {
  description = "ID of the ECR DKR VPC endpoint"
  value       = var.enable_vpc_endpoints ? aws_vpc_endpoint.ecr_dkr.id : null
}
