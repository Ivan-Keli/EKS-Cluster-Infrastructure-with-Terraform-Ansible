# terraform/environments/dev/main.tf
# Purpose: Main configuration that orchestrates all modules for dev environment

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

# Configure AWS Provider
provider "aws" {
  region = var.region
  
  default_tags {
    tags = local.common_tags
  }
}

# Local variables
locals {
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
      CreatedAt   = timestamp()
    }
  )
  
  cluster_name = "${var.project_name}-${var.environment}"
}

# VPC Module
module "vpc" {
  source = "../../modules/vpc"
  
  cluster_name        = local.cluster_name
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  region             = var.region
  tags               = local.common_tags
}

# Networking Module (NAT Gateway)
module "networking" {
  source = "../../modules/networking"
  
  cluster_name           = local.cluster_name
  vpc_id                = module.vpc.vpc_id
  public_subnet_id      = module.vpc.public_subnet_id
  private_subnet_id     = module.vpc.private_subnet_id
  private_subnet_cidr   = module.vpc.private_subnet_cidr
  private_route_table_id = module.vpc.private_route_table_id
  internet_gateway_id   = module.vpc.internet_gateway_id
  region                = var.region
  tags                  = local.common_tags
  enable_vpc_endpoints  = var.enable_vpc_endpoints
  
  depends_on = [module.vpc]
}

# EKS Cluster Module
module "eks" {
  source = "../../modules/eks"
  
  cluster_name            = local.cluster_name
  kubernetes_version      = var.kubernetes_version
  vpc_id                 = module.vpc.vpc_id
  subnet_ids             = module.vpc.subnet_ids
  endpoint_private_access = var.endpoint_private_access
  endpoint_public_access  = var.endpoint_public_access
  public_access_cidrs    = var.public_access_cidrs
  cluster_log_types      = var.cluster_log_types
  enable_ssh_access      = var.enable_ssh_access
  ssh_access_cidrs       = var.ssh_access_cidrs
  tags                   = local.common_tags
  
  # Pass OIDC provider info for IRSA roles
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  
  depends_on = [module.networking]
}

# Node Group Module
module "node_group" {
  source = "../../modules/node_group"
  
  cluster_name                       = local.cluster_name
  cluster_id                        = module.eks.cluster_id
  cluster_endpoint                  = module.eks.cluster_endpoint
  cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data
  kubernetes_version                = var.kubernetes_version
  node_iam_role_arn                = module.eks.node_iam_role_arn
  node_security_group_id            = module.eks.node_security_group_id
  subnet_ids                        = [module.vpc.private_subnet_id]  # Nodes in private subnet
  instance_type                     = var.node_instance_type
  disk_size                        = var.node_disk_size
  min_size                         = var.node_min_size
  desired_size                     = var.node_desired_size
  max_size                         = var.node_max_size
  key_name                         = var.key_name
  enable_monitoring                = var.enable_monitoring
  enable_autoscaling              = var.enable_autoscaling
  cpu_threshold_high              = var.cpu_threshold_high
  cpu_threshold_low               = var.cpu_threshold_low
  bootstrap_arguments             = var.bootstrap_arguments
  kubernetes_labels               = var.kubernetes_labels
  tags                           = local.common_tags
  
  depends_on = [module.eks]
}

# Generate kubeconfig for cluster access
resource "local_file" "kubeconfig" {
  count = var.create_kubeconfig ? 1 : 0
  
  content = templatefile("${path.module}/templates/kubeconfig.tpl", {
    cluster_name     = local.cluster_name
    endpoint        = module.eks.cluster_endpoint
    certificate_data = module.eks.cluster_certificate_authority_data
    region          = var.region
  })
  
  filename             = "${path.root}/kubeconfig_${local.cluster_name}"
  file_permission      = "0600"
  directory_permission = "0755"
}
