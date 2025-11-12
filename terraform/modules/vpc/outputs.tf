# terraform/modules/vpc/outputs.tf
# Purpose: Output values from VPC module for use by other modules

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private.id
}

output "public_subnet_cidr" {
  description = "CIDR block of public subnet"
  value       = aws_subnet.public.cidr_block
}

output "private_subnet_cidr" {
  description = "CIDR block of private subnet"
  value       = aws_subnet.private.cidr_block
}

output "private_route_table_id" {
  description = "ID of the private route table (for NAT Gateway route)"
  value       = aws_route_table.private.id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "subnet_ids" {
  description = "List of subnet IDs"
  value       = [aws_subnet.public.id, aws_subnet.private.id]
}
