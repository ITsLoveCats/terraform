#!/bin/bash

if [ ! -f /disableStartupScript ]; then

# download package & upgrades of all packages
apt update
apt upgrade -y


#############################
# 1. Setup Containerd Runtime 
#############################

wall "1. Configure Runtime Prerequisites:"

cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

# Setup required sysctl params, these persist across reboots.
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply sysctl params without reboot
sysctl --system


#######################################
# 2. Install containerd & Docker Engine
#######################################

wall "2. Install containerd"

# 2.1 Install Docker Engine.
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm get-docker.sh

# 2.2 Configure containerd
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml

# 2.3 Restart containerd:
systemctl restart containerd


####################################
# 3. Configure systemd cgroup driver
####################################

wall "3. Using the systemd cgroup driver"

sed -i '/\[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options\]/ a \\t\ \ \ \ SystemdCgroup = true' /etc/containerd/config.toml 
systemctl restart containerd


#########################################
# 4. Letting iptables see bridged traffic 
#########################################

wall "4. Letting iptables see bridged traffic "

# Letting iptables see bridged traffic 
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system


#######################
# 5. disable swap & ufw
#######################

wall "5. disable swap & ufw"

echo "disable swap"
swapoff -a

echo "disable ufw"
ufw disable


############################################
# 6. Installing kubeadm, kubelet and kubectl 
############################################

wall "6. Installing kubeadm, kubelet and kubectl"

apt-get install -y apt-transport-https ca-certificates curl
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

####################################
# 7. Installing a Pod network add-on 
####################################

wall "7. set CALICO_IPV4POOL_CIDR"

wget https://docs.projectcalico.org/manifests/calico.yaml
sed -i 's/# - name: CALICO_IPV4POOL_CIDR/- name: CALICO_IPV4POOL_CIDR/g' calico.yaml

# This line will setup 192.68.0.0 as pod networking
sed -i 's/#   value: "192.168.0.0\/16"/  value: "192.168.0.0\/16"/g' calico.yaml
chown 755 calico.yaml
mv calico.yaml /tmp/calico.yaml

###################
# 8. Set /etc/hosts
###################

wall "8. Set /etc/hosts"

echo "$(hostname -i) $(hostname)" >> /etc/hosts

################################
# 9. Set kubectl bash completion
################################

wall "9. bash completion, need sign-out to take effect"

apt-get install bash-completion -y
echo 'source <(kubectl completion bash)' >>~/.bashrc
kubectl completion bash >/etc/bash_completion.d/kubectl


###########################
# 10. Create a wall message
###########################

cat <<EOF | sudo tee /ThingsToDo_as_a_master

# in order to create a cluster with kubeadm
sudo kubeadm init --cri-socket /run/containerd/containerd.sock

# Installing a Pod network add-on 
kubectl apply --filename=/tmp/calico.yaml

# Get pods health
kubectl get pods --all-namespaces
EOF

wall /ThingsToDo_as_a_master

####################################
# 11. Create a state file (GCE only)
####################################

# Add a state for Google Compute Engine Startup Script
touch /disableStartupScript

fi