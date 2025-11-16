# Setting Up Kubernetes Cluster with Kind on Ubuntu

This guide provides comprehensive instructions for setting up a Kubernetes cluster using Kind (Kubernetes in Docker) on Ubuntu, including WSL2-specific configurations for Windows users.

## Overview

Kind (Kubernetes in Docker) is a tool for running local Kubernetes clusters using Docker container "nodes". This setup provides:

- Single or multi-node Kubernetes clusters
- Easy cluster creation and destruction
- Development and testing environment
- Integration with CI/CD pipelines

## Prerequisites

Before you begin, ensure you have the following prerequisites:

- **Ubuntu 20.04+ or WSL2 Ubuntu**: A working Ubuntu instance
- **Docker**: Docker Engine installed and running
- **Adequate system resources**: Minimum 4GB RAM, 2 CPU cores
- **Internet connection**: For downloading images and packages

## Step 1: Install Docker

If Docker is not already installed, install it first:

```bash
# Update package index
sudo apt-get update

# Install required packages
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Add your user to the docker group
sudo usermod -aG docker $USER

# Start and enable Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Verify Docker installation
docker --version
```

**Note**: After adding your user to the docker group, you'll need to log out and back in for the changes to take effect.

## Step 2: Install Kind

Install Kind using one of the following methods:

### Method 1: Using Snap (Recommended)

```bash
sudo snap install kind
```

### Method 2: Using Binary Installation

```bash
# Download the latest Kind binary
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64

# Make it executable
chmod +x ./kind

# Move to a directory in your PATH
sudo mv ./kind /usr/local/bin/kind

# Verify installation
kind version
```

## Step 3: Install kubectl

Install kubectl to interact with your Kubernetes cluster:

```bash
# Download kubectl binary
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Make it executable
chmod +x kubectl

# Move to a directory in your PATH
sudo mv kubectl /usr/local/bin/

# Verify installation
kubectl version --client
```

## Step 4: Create a Kind Cluster

### Basic Single-Node Cluster

Create a simple single-node cluster:

```bash
# Create a basic cluster
kind create cluster --name my-cluster

# Verify cluster creation
kind get clusters
kubectl cluster-info --context kind-my-cluster
```

### Multi-Node Cluster

For a more realistic setup, create a multi-node cluster:

```bash
# Create a configuration file for multi-node cluster
cat << EOF > kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 6443
    hostPort: 6443
    protocol: TCP
- role: worker
- role: worker
EOF

# Create the multi-node cluster
kind create cluster --name multi-node-cluster --config kind-config.yaml

# Verify nodes
kubectl get nodes
```

## Step 5: Configure Cluster Access

Set up kubectl to work with your Kind cluster:

```bash
# Set the context to your Kind cluster
kubectl cluster-info --context kind-my-cluster

# Verify you can access the cluster
kubectl get nodes
kubectl get pods --all-namespaces
```

## Step 6: Install Essential Add-ons

### Install Ingress Controller

```bash
# Install NGINX Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Wait for the ingress controller to be ready
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s
```

### Install MetalLB (Load Balancer)

```bash
# Install MetalLB
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml

# Wait for MetalLB to be ready
kubectl wait --namespace metallb-system \
  --for=condition=ready pod \
  --selector=app=metallb \
  --timeout=120s

# Configure MetalLB IP range (adjust for your network)
cat << EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: first-pool
  namespace: metallb-system
spec:
  addresses:
  - 172.18.255.200-172.18.255.250
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: example
  namespace: metallb-system
spec:
  ipAddressPools:
  - first-pool
EOF
```

### Install Cert-Manager (Optional)

```bash
# Install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# Wait for cert-manager to be ready
kubectl wait --namespace cert-manager \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/instance=cert-manager \
  --timeout=120s
```

## Step 7: Install Kubernetes Dashboard

```bash
# Install the dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

# Create a service account for dashboard access
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF

# Get the access token
kubectl -n kubernetes-dashboard create token admin-user
```

## Step 8: WSL2 Port Forwarding (Windows Users)

For WSL2 users, set up port forwarding to access services from Windows:

```bash
# Get WSL2 IP address
WSL_IP=$(hostname -I | awk '{print $1}')

# Create a port forwarding script
cat << 'EOF' > ~/setup-port-forwarding.sh
#!/bin/bash
WSL_IP=$(hostname -I | awk '{print $1}')

# Forward common Kubernetes ports
powershell.exe -Command "netsh interface portproxy add v4tov4 listenport=80 listenaddress=0.0.0.0 connectport=80 connectaddress=$WSL_IP"
powershell.exe -Command "netsh interface portproxy add v4tov4 listenport=443 listenaddress=0.0.0.0 connectport=443 connectaddress=$WSL_IP"
powershell.exe -Command "netsh interface portproxy add v4tov4 listenport=30000 listenaddress=0.0.0.0 connectport=30000 connectaddress=$WSL_IP"
powershell.exe -Command "netsh interface portproxy add v4tov4 listenport=30001 listenaddress=0.0.0.0 connectport=30001 connectaddress=$WSL_IP"

echo "Port forwarding configured for WSL2 IP: $WSL_IP"
EOF

# Make the script executable
chmod +x ~/setup-port-forwarding.sh

# Run the script
~/setup-port-forwarding.sh
```

## Step 9: Verify Installation

Test your cluster with a sample application:

```bash
# Create a test deployment
kubectl create deployment nginx --image=nginx:latest

# Expose the deployment
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# Check the deployment
kubectl get deployments
kubectl get services
kubectl get pods

# Test the application (if using WSL2 with port forwarding)
curl http://localhost
```

## Step 10: Cluster Management

### Useful Commands

```bash
# List all clusters
kind get clusters

# Switch between clusters
kubectl config use-context kind-my-cluster

# Get cluster information
kubectl cluster-info

# View all resources
kubectl get all --all-namespaces

# Access dashboard (in a new terminal)
kubectl proxy
# Then visit: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```

### Stop and Start Clusters

```bash
# Stop a cluster
kind stop --name my-cluster

# Start a stopped cluster
kind start --name my-cluster

# Delete a cluster
kind delete cluster --name my-cluster
```

## Troubleshooting

### Common Issues

#### Docker Permission Issues

```bash
# If you get permission errors with Docker
sudo chmod 666 /var/run/docker.sock
# Or restart your session after adding user to docker group
```

#### Port Conflicts

```bash
# Check what's using a port
sudo netstat -tulpn | grep :6443

# Remove port forwarding if needed
powershell.exe -Command "netsh interface portproxy delete v4tov4 listenport=80"
```

#### Cluster Creation Fails

```bash
# Check Docker status
docker info

# Check available resources
free -h
df -h

# Clean up Docker
docker system prune -a
```

### Performance Optimization

For better performance in WSL2:

```bash
# Create or edit .wslconfig in Windows
# Add to C:\Users\<username>\.wslconfig:
[wsl2]
memory=8GB
processors=4
swap=2GB
```

## Next Steps

After setting up your Kind cluster, consider:

1. **Installing Helm**: Package manager for Kubernetes
2. **Setting up monitoring**: Prometheus and Grafana
3. **Configuring logging**: ELK stack or similar
4. **Setting up CI/CD**: ArgoCD or Tekton
5. **Security hardening**: Network policies, RBAC

## Cleanup

To completely remove your Kind setup:

```bash
# Delete all clusters
kind delete cluster --all

# Remove Kind binary
sudo snap remove kind
# Or: sudo rm /usr/local/bin/kind

# Remove kubectl
sudo rm /usr/local/bin/kubectl

# Clean up Docker images
docker system prune -a
```

This setup provides a complete, production-like Kubernetes environment for development and testing purposes.
