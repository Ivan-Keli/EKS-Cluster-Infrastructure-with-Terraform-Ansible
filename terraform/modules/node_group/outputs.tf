# terraform/modules/node_group/outputs.tf
# Purpose: Output values from node group module

output "node_group_id" {
  description = "EKS node group ID"
  value       = aws_eks_node_group.main.id
}

output "node_group_arn" {
  description = "ARN of the EKS node group"
  value       = aws_eks_node_group.main.arn
}

output "node_group_status" {
  description = "Status of the EKS node group"
  value       = aws_eks_node_group.main.status
}

output "node_group_resources" {
  description = "Resources associated with the node group"
  value       = aws_eks_node_group.main.resources
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = try(aws_eks_node_group.main.resources[0].autoscaling_groups[0].name, "")
}

output "autoscaling_group_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = try(aws_eks_node_group.main.resources[0].autoscaling_groups[0].arn, "")
}

output "launch_template_id" {
  description = "ID of the launch template"
  value       = aws_launch_template.eks_nodes.id
}

output "launch_template_latest_version" {
  description = "Latest version of the launch template"
  value       = aws_launch_template.eks_nodes.latest_version
}

output "remote_access_security_group_id" {
  description = "Remote access security group ID"
  value       = try(aws_eks_node_group.main.resources[0].remote_access_security_group_id, "")
}

output "scale_up_policy_arn" {
  description = "ARN of the scale up policy"
  value       = var.enable_autoscaling ? aws_autoscaling_policy.scale_up[0].arn : null
}

output "scale_down_policy_arn" {
  description = "ARN of the scale down policy"
  value       = var.enable_autoscaling ? aws_autoscaling_policy.scale_down[0].arn : null
}
