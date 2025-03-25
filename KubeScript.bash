#!/bin/bash

# Opdater systemet
echo "Updating system..."
sudo apt-get update -y

# Deaktiver swap (krævet for Kubernetes)
echo "Disabling swap..."
sudo swapoff -a

# Konfigurer netværksindstillinger
echo "Configuring sysctl settings..."
cat <<EOF | sudo tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Anvend ændringer
echo "Applying sysctl changes..."
sudo sysctl --system

# Installer container runtime (containerd)
echo "Installing containerd..."
sudo apt-get install -y containerd

# Installer nødvendige pakker til Kubernetes
echo "Installing Kubernetes dependencies..."
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# Hent Kubernetes’ officielle GPG-nøgle
echo "Downloading Kubernetes GPG key..."
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Tilføj Kubernetes repository
echo "Adding Kubernetes repository..."
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Opdater systemet igen for at inkludere Kubernetes repo
echo "Updating system after adding Kubernetes repository..."
sudo apt-get update

# Installer kubelet, kubeadm og kubectl
echo "Installing kubelet, kubeadm, and kubectl..."
sudo apt-get install -y kubelet kubeadm kubectl

# Sikrer at kubelet starter automatisk ved boot
echo "Enabling and starting kubelet service..."
sudo systemctl enable kubelet
sudo systemctl start kubelet

echo "Please enter the join command from the master node:"
read JOIN_COMMAND

# Tilslut worker node til master node
echo "Joining the worker node to the Kubernetes cluster..."
$JOIN_COMMAND

echo "Worker node setup complete!"
