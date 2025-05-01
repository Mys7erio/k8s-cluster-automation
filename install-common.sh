#!/bin/bash

set -euo pipefail

# ================ GLOBAL VARIABLES ================
export PLATFORM=linux-arm64

export KUBERNETES_VERSION=v1.33
export CONTAINERD_VERSION=2.0.4
# ================ GLOBAL VARIABLES ================

# Update and install common utilities & necessary packages
sudo apt-get update
sudo apt-get install -y curl wget nano vim tmux less \
                        apt-transport-https ca-certificates curl gpg


# Configure firewall:
#   - Flush all existing rules
#   - Delete all user defined chains, , and
#   - Allow all incoming traffic
# TODO: Block all incoming traffic by default, and manually K8s ports to whitelist (Zero Trust Policy)
sudo iptables -F
sudo iptables -X
sudo iptables -P INPUT ACCEPT


# Disable SWAP
# Skipping because SWAP seems to be disabled by default on ubuntu machines, oracle arm instances


# Enable IP Forwarding permanently, and apply changes now
sudo tee /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system


# Load required kernel modules
sudo modprobe overlay
sudo modprobe br_netfilter


# Install a container runtime (containerd)
curl -sL https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VERSION}/containerd-${CONTAINERD_VERSION}-${PLATFORM}.tar.gz | \
    sudo tar xzvf - -C /usr/local

# Install the containerd service file at the correct location, and enable it immediately
sudo mkdir -p /usr/local/lib/systemd/system # By default this directly doesn't exist
curl -sL https://raw.githubusercontent.com/containerd/containerd/main/containerd.service | sudo tee /usr/local/lib/systemd/system/containerd.service
sudo systemctl daemon-reload
sudo systemctl enable --now containerd


# Install runc
# $ install -m 755 runc.amd64 /usr/local/sbin/runc
sudo curl -sL https://github.com/opencontainers/runc/releases/download/v1.3.0/runc.arm64 -o /usr/local/sbin/runc
sudo chmod 755 /usr/local/sbin/runc


# Install kubeadm, kubectl and kubectl
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add kubernetes repository to apt lists
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/${KUBERNETES_VERSION}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update and install k8s components
sudo apt-get update
sudo apt-get install -y kubeadm kubelet kubectl
sudo apt-mark hold kubeadm kubelet kubectl

# Enable the kubelet service
sudo systemctl enable --now kubelet