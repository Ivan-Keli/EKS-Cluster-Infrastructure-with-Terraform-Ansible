# terraform/modules/eks/security_groups.tf
# Purpose: Security groups for EKS cluster and node communication

# Security Group for EKS Cluster
resource "aws_security_group" "eks_cluster" {
  name        = "${var.cluster_name}-cluster-sg"
  description = "Security group for ${var.cluster_name} EKS cluster"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-cluster-sg"
    }
  )
}

# Allow inbound traffic from nodes
resource "aws_security_group_rule" "cluster_ingress_node_https" {
  description              = "Allow nodes to communicate with cluster API"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 443
  type                     = "ingress"
}

# Allow outbound traffic to nodes
resource "aws_security_group_rule" "cluster_egress_node" {
  description              = "Allow cluster to communicate with nodes"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 65535
  type                     = "egress"
}

# Allow outbound traffic for kubelet and pods
resource "aws_security_group_rule" "cluster_egress_kubelet" {
  description              = "Allow cluster to communicate with kubelet on nodes"
  from_port                = 10250
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 10250
  type                     = "egress"
}

# Security Group for EKS Nodes
resource "aws_security_group" "eks_nodes" {
  name        = "${var.cluster_name}-node-sg"
  description = "Security group for ${var.cluster_name} EKS nodes"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name                                         = "${var.cluster_name}-node-sg"
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
  )
}

# Allow nodes to communicate with each other
resource "aws_security_group_rule" "nodes_ingress_self" {
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 65535
  type                     = "ingress"
}

# Allow nodes to communicate with cluster API
resource "aws_security_group_rule" "nodes_ingress_cluster" {
  description              = "Allow nodes to receive communication from cluster"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_cluster.id
  to_port                  = 65535
  type                     = "ingress"
}

# Allow kubelet traffic from cluster
resource "aws_security_group_rule" "nodes_ingress_kubelet" {
  description              = "Allow kubelet to receive communication from cluster"
  from_port                = 10250
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_cluster.id
  to_port                  = 10250
  type                     = "ingress"
}

# Allow all outbound traffic from nodes
resource "aws_security_group_rule" "nodes_egress_all" {
  description       = "Allow nodes all outbound traffic"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.eks_nodes.id
  cidr_blocks       = ["0.0.0.0/0"]
  to_port           = 0
  type              = "egress"
}

# Allow nodes to communicate with cluster API server
resource "aws_security_group_rule" "nodes_egress_cluster" {
  description              = "Allow nodes to communicate with cluster API"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_cluster.id
  to_port                  = 443
  type                     = "egress"
}

# Allow SSH access to nodes (optional, for debugging)
resource "aws_security_group_rule" "nodes_ssh_ingress" {
  count             = var.enable_ssh_access ? 1 : 0
  description       = "Allow SSH access to nodes"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.eks_nodes.id
  cidr_blocks       = var.ssh_access_cidrs
  to_port           = 22
  type              = "ingress"
}

# Security group for pods (if using security groups for pods feature)
resource "aws_security_group" "eks_pods" {
  count       = var.enable_pod_security_groups ? 1 : 0
  name        = "${var.cluster_name}-pod-sg"
  description = "Security group for ${var.cluster_name} EKS pods"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-pod-sg"
    }
  )
}

# Allow pods to communicate with each other
resource "aws_security_group_rule" "pods_ingress_self" {
  count                    = var.enable_pod_security_groups ? 1 : 0
  description              = "Allow pods to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_pods[0].id
  source_security_group_id = aws_security_group.eks_pods[0].id
  to_port                  = 65535
  type                     = "ingress"
}

# Allow all outbound traffic from pods
resource "aws_security_group_rule" "pods_egress_all" {
  count             = var.enable_pod_security_groups ? 1 : 0
  description       = "Allow pods all outbound traffic"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.eks_pods[0].id
  cidr_blocks       = ["0.0.0.0/0"]
  to_port           = 0
  type              = "egress"
}
