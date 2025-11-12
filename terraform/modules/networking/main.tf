# terraform/modules/networking/main.tf
# Purpose: Creates NAT Gateway and configures routing for private subnet internet access

# Allocate Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
  
  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-nat-eip"
    }
  )

  # Ensure proper ordering of resource creation
  depends_on = [var.internet_gateway_id]
}

# Create NAT Gateway in public subnet
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = var.public_subnet_id

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-nat-gateway"
    }
  )

  # To ensure proper ordering, we depend on the Internet Gateway
  depends_on = [var.internet_gateway_id]
}

# Create route for private subnet to NAT Gateway
resource "aws_route" "private_nat" {
  route_table_id         = var.private_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

# Security Group for NAT Gateway traffic
resource "aws_security_group" "nat" {
  name        = "${var.cluster_name}-nat-sg"
  description = "Security group for NAT Gateway"
  vpc_id      = var.vpc_id

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow inbound traffic from private subnet
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.private_subnet_cidr]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-nat-sg"
    }
  )
}

# VPC Endpoints for AWS services (optional but recommended for EKS)
# S3 endpoint for pulling container images
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${var.region}.s3"
  
  route_table_ids = [var.private_route_table_id]

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-s3-endpoint"
    }
  )
}

# ECR API endpoint for container registry
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [var.private_subnet_id]
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-ecr-api-endpoint"
    }
  )
}

# ECR DKR endpoint for container registry
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [var.private_subnet_id]
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-ecr-dkr-endpoint"
    }
  )
}

# Security Group for VPC Endpoints
resource "aws_security_group" "vpc_endpoints" {
  name        = "${var.cluster_name}-vpc-endpoints-sg"
  description = "Security group for VPC endpoints"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.private_subnet_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-vpc-endpoints-sg"
    }
  )
}
