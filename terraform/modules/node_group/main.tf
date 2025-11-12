# terraform/modules/node_group/main.tf
# Purpose: Creates EKS managed node group with t3.micro instances

# Data source for latest Amazon Linux 2 EKS AMI
data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${var.kubernetes_version}/amazon-linux-2/recommended/release_version"
}

# Launch template for node group (provides more control than default)
resource "aws_launch_template" "eks_nodes" {
  name_prefix = "${var.cluster_name}-node-"
  description = "Launch template for ${var.cluster_name} EKS nodes"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.disk_size
      volume_type          = "gp3"
      iops                 = 3000
      throughput           = 125
      encrypted            = true
      delete_on_termination = true
    }
  }

  instance_type = var.instance_type

  key_name = var.key_name

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }

  monitoring {
    enabled = var.enable_monitoring
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups            = [var.node_security_group_id]
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(
      var.tags,
      {
        Name = "${var.cluster_name}-eks-node"
      }
    )
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(
      var.tags,
      {
        Name = "${var.cluster_name}-eks-node-volume"
      }
    )
  }

  user_data = base64encode(templatefile("${path.module}/user_data.tpl", {
    cluster_name        = var.cluster_name
    cluster_endpoint    = var.cluster_endpoint
    cluster_ca_data     = var.cluster_certificate_authority_data
    bootstrap_arguments = var.bootstrap_arguments
  }))

  tags = var.tags
}

# EKS Managed Node Group
resource "aws_eks_node_group" "main" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = var.node_iam_role_arn
  subnet_ids      = var.subnet_ids
  version         = var.kubernetes_version

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  update_config {
    max_unavailable_percentage = 33
  }

  launch_template {
    id      = aws_launch_template.eks_nodes.id
    version = aws_launch_template.eks_nodes.latest_version
  }

  # Ensure proper order of resource creation and deletion
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config[0].desired_size]
  }

  labels = merge(
    var.kubernetes_labels,
    {
      role = "worker"
      instance_type = var.instance_type
    }
  )

  taints = var.kubernetes_taints

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-eks-node-group"
    }
  )

  depends_on = [
    var.cluster_id
  ]
}

# Auto Scaling policies for the node group
resource "aws_autoscaling_policy" "scale_up" {
  count                  = var.enable_autoscaling ? 1 : 0
  name                   = "${var.cluster_name}-node-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 300
  autoscaling_group_name = aws_eks_node_group.main.resources[0].autoscaling_groups[0].name
}

resource "aws_autoscaling_policy" "scale_down" {
  count                  = var.enable_autoscaling ? 1 : 0
  name                   = "${var.cluster_name}-node-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown              = 300
  autoscaling_group_name = aws_eks_node_group.main.resources[0].autoscaling_groups[0].name
}

# CloudWatch alarms for autoscaling
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count               = var.enable_autoscaling ? 1 : 0
  alarm_name          = "${var.cluster_name}-node-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "CPUUtilization"
  namespace          = "AWS/EC2"
  period             = "300"
  statistic          = "Average"
  threshold          = var.cpu_threshold_high
  alarm_description  = "This metric monitors node cpu utilization"
  alarm_actions      = [aws_autoscaling_policy.scale_up[0].arn]

  dimensions = {
    AutoScalingGroupName = aws_eks_node_group.main.resources[0].autoscaling_groups[0].name
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  count               = var.enable_autoscaling ? 1 : 0
  alarm_name          = "${var.cluster_name}-node-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "CPUUtilization"
  namespace          = "AWS/EC2"
  period             = "300"
  statistic          = "Average"
  threshold          = var.cpu_threshold_low
  alarm_description  = "This metric monitors node cpu utilization"
  alarm_actions      = [aws_autoscaling_policy.scale_down[0].arn]

  dimensions = {
    AutoScalingGroupName = aws_eks_node_group.main.resources[0].autoscaling_groups[0].name
  }
}
