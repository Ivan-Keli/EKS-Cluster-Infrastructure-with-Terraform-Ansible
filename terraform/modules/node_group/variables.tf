# terraform/modules/node_group/variables.tf
# Purpose: Input variables for node group module

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_id" {
  description = "ID/name of the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  type        = string
}

variable "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the node group"
  type        = string
  default     = "1.28"
}

variable "node_iam_role_arn" {
  description = "IAM role ARN for the node group"
  type        = string
}

variable "node_security_group_id" {
  description = "Security group ID for nodes"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for node placement"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type for nodes"
  type        = string
  default     = "t3.micro"
}

variable "disk_size" {
  description = "Disk size in GB for worker nodes"
  type        = number
  default     = 20
}

variable "min_size" {
  description = "Minimum size of the node group"
  type        = number
  default     = 1
}

variable "desired_size" {
  description = "Desired size of the node group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum size of the node group"
  type        = number
  default     = 3
}

variable "key_name" {
  description = "Name of the EC2 key pair for SSH access"
  type        = string
  default     = ""
}

variable "enable_monitoring" {
  description = "Enable detailed monitoring for instances"
  type        = bool
  default     = false
}

variable "enable_autoscaling" {
  description = "Enable autoscaling for the node group"
  type        = bool
  default     = true
}

variable "cpu_threshold_high" {
  description = "CPU threshold for scaling up"
  type        = number
  default     = 70
}

variable "cpu_threshold_low" {
  description = "CPU threshold for scaling down"
  type        = number
  default     = 30
}

variable "bootstrap_arguments" {
  description = "Additional arguments for EKS bootstrap script"
  type        = string
  default     = ""
}

variable "kubernetes_labels" {
  description = "Key-value mapping of Kubernetes labels"
  type        = map(string)
  default     = {}
}

variable "kubernetes_taints" {
  description = "List of Kubernetes taints to apply to nodes"
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
