# terraform/modules/eks/outputs.tf
# Purpose: Output values from EKS module

output "cluster_id" {
  description = "Name/ID of the EKS cluster"
  value       = aws_eks_cluster.main.id
}

output "cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = aws_eks_cluster.main.arn
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_security_group.eks_cluster.id
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_version" {
  description = "The Kubernetes server version for the cluster"
  value       = aws_eks_cluster.main.version
}

output "node_security_group_id" {
  description = "Security group ID for EKS nodes"
  value       = aws_security_group.eks_nodes.id
}

output "node_iam_role_arn" {
  description = "IAM role ARN for EKS nodes"
  value       = aws_iam_role.eks_node_group.arn
}

output "node_iam_role_name" {
  description = "IAM role name for EKS nodes"
  value       = aws_iam_role.eks_node_group.name
}

output "node_instance_profile_name" {
  description = "Instance profile name for EKS nodes"
  value       = aws_iam_instance_profile.eks_node.name
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC Provider for EKS"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "oidc_provider_url" {
  description = "URL of the OIDC Provider for EKS"
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "ebs_csi_driver_role_arn" {
  description = "IAM role ARN for EBS CSI driver"
  value       = aws_iam_role.ebs_csi_driver.arn
}

output "alb_controller_role_arn" {
  description = "IAM role ARN for AWS Load Balancer Controller"
  value       = aws_iam_role.alb_controller.arn
}

output "pod_security_group_id" {
  description = "Security group ID for pods (if enabled)"
  value       = var.enable_pod_security_groups ? aws_security_group.eks_pods[0].id : null
}

output "kms_key_id" {
  description = "The Amazon Resource Name (ARN) of the KMS key"
  value       = var.kms_key_arn == "" ? aws_kms_key.eks[0].arn : var.kms_key_arn
}
