# terraform/modules/networking/variables.tf
# Purpose: Input variables for networking module

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "public_subnet_id" {
  description = "ID of the public subnet where NAT Gateway will be placed"
  type        = string
}

variable "private_subnet_id" {
  description = "ID of the private subnet that will route through NAT"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block of the private subnet"
  type        = string
}

variable "private_route_table_id" {
  description = "ID of the private route table"
  type        = string
}

variable "internet_gateway_id" {
  description = "ID of the Internet Gateway (for dependency)"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "enable_vpc_endpoints" {
  description = "Enable VPC endpoints for AWS services"
  type        = bool
  default     = true
}
