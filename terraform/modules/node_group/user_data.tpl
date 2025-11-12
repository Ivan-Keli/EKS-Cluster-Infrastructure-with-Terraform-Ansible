#!/bin/bash
# terraform/modules/node_group/user_data.tpl
# Purpose: Bootstrap script for EKS nodes

# Update and install necessary packages
yum update -y

# Configure EKS bootstrap
/etc/eks/bootstrap.sh ${cluster_name} \
  --b64-cluster-ca ${cluster_ca_data} \
  --apiserver-endpoint ${cluster_endpoint} \
  ${bootstrap_arguments}

# Install additional tools for troubleshooting
yum install -y \
  amazon-ssm-agent \
  htop \
  tcpdump \
  vim \
  git

# Start SSM agent for Session Manager access
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent

# Configure Docker daemon
cat <<EOF > /etc/docker/daemon.json
{
  "bridge": "none",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "10"
  },
  "live-restore": true,
  "max-concurrent-downloads": 10
}
EOF

# Restart Docker to apply settings
systemctl restart docker

# Set up log rotation for kubelet
cat <<EOF > /etc/logrotate.d/kubelet
/var/log/pods/*/*.log {
    rotate 5
    daily
    maxage 14
    missingok
    notifempty
    compress
    size 50M
    sharedscripts
}
EOF

# Optimize kernel parameters for containers
cat <<EOF >> /etc/sysctl.conf
# Increase the number of connections
net.core.somaxconn = 32768

# Increase the maximum number of open files
fs.file-max = 2097152

# Increase the maximum number of inotify watches
fs.inotify.max_user_watches = 524288

# Optimize network settings for containers
net.ipv4.tcp_tw_reuse = 1
net.ipv4.ip_local_port_range = 1024 65535
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply sysctl settings
sysctl -p

# Configure kubelet for better resource management
cat <<EOF > /etc/kubernetes/kubelet/kubelet-config.json
{
  "kubeReserved": {
    "cpu": "100m",
    "memory": "100Mi"
  },
  "systemReserved": {
    "cpu": "100m",
    "memory": "100Mi"
  },
  "evictionHard": {
    "memory.available": "100Mi",
    "nodefs.available": "10%"
  },
  "maxPods": 20
}
EOF

# Signal successful bootstrap
echo "Node bootstrap completed successfully" > /var/log/node-bootstrap.log
