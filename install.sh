#!/bin/bash

set -e

LOG_FILE="installer.log"
exec > >(tee -i "$LOG_FILE") 2>&1

echo "$(date +'%Y-%m-%d %H:%M:%S') - Updating and upgrading the system..."
apt update && apt upgrade -y

echo "$(date +'%Y-%m-%d %H:%M:%S') - Installing necessary packages..."
apt-get update
DEBIAN_FRONTEND=noninteractive TZ=Europe/Istanbul apt-get -y install tzdata
apt-get install -y vim nano wget net-tools locales bzip2 wmctrl software-properties-common jq curl apt-transport-https ca-certificates
locale-gen tr_TR.UTF-8
timedatectl set-timezone Europe/Istanbul
timedatectl set-ntp no

echo "$(date +'%Y-%m-%d %H:%M:%S') - Setting up Docker and Containerd packages..."
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

echo "$(date +'%Y-%m-%d %H:%M:%S') - Configuring kernel modules for containerd..."
cat <<EOF | tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

echo "$(date +'%Y-%m-%d %H:%M:%S') - Configuring system settings for Kubernetes..."
cat <<EOF | tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sysctl --system

echo "$(date +'%Y-%m-%d %H:%M:%S') - Configuring containerd settings..."
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml > /dev/null

echo "$(date +'%Y-%m-%d %H:%M:%S') - Editing /etc/containerd/config.toml to enable SystemdCgroup..."
sed -i '/\[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options\]/a \    SystemdCgroup = true' /etc/containerd/config.toml
systemctl restart containerd

echo "$(date +'%Y-%m-%d %H:%M:%S') - Installing kubernetes applications..."
cat <<EOF |  tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF
cat <<EOF |  tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key |  gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' |  tee /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-cache madison kubeadm
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl
kubeadm version -o yaml

echo "$(date +'%Y-%m-%d %H:%M:%S') - Setup completed successfully!"
