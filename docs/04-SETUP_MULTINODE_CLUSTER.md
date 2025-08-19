# Setting Up Multi-Node Kubernetes Clusters

This guide provides comprehensive instructions for setting up multi-node Kubernetes clusters using different tools, with a focus on the most appropriate solutions for various use cases.

## Overview

When setting up multi-node Kubernetes clusters locally, you have several options:

- **Kind (Kubernetes in Docker)**: Recommended for multi-node development clusters
- **K3d**: Lightweight alternative to Kind
- **Minikube**: Limited multi-node support, better for single-node development
- **K3s**: Lightweight production-ready Kubernetes

## Prerequisites

Before you begin, ensure you have:

- **Docker**: Docker Engine installed and running
- **Adequate system resources**: Minimum 8GB RAM, 4 CPU cores for multi-node clusters
- **Internet connection**: For downloading images and packages
- **kubectl**: Kubernetes command-line tool

## Option 1: Kind (Recommended for Multi-Node)

Kind is the most popular and reliable tool for creating multi-node Kubernetes clusters locally.

### Installation

```bash
# Install Kind using Snap (Ubuntu)
sudo snap install kind

# Or download the binary
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Verify installation
kind version
```

### Create Multi-Node Cluster

1. **Create a configuration file** (`kind-multinode-config.yaml`):

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: multinode-cluster
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 6443
    hostPort: 6443
    protocol: TCP
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
- role: worker
- role: worker
- role: worker
```

2. **Create the cluster**:

```bash
# Create the multi-node cluster
kind create cluster --config kind-multinode-config.yaml

# Verify cluster creation
kind get clusters
kubectl cluster-info --context kind-multinode-cluster
kubectl get nodes
```

3. **Verify node roles**:

```bash
# Check node labels and roles
kubectl get nodes --show-labels
kubectl get nodes -o wide
```

### Cluster Management

```bash
# List all clusters
kind get clusters

# Switch context
kubectl config use-context kind-multinode-cluster

# Stop the cluster
kind stop --name multinode-cluster

# Start the cluster
kind start --name multinode-cluster

# Delete the cluster
kind delete cluster --name multinode-cluster
```

## Option 2: K3d (Lightweight Alternative)

K3d is a lightweight wrapper around K3s, providing fast multi-node cluster creation.

### Installation

```bash
# Install K3d
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Verify installation
k3d version
```

### Create Multi-Node Cluster

```bash
# Create a multi-node cluster
k3d cluster create multinode-cluster \
  --servers 1 \
  --agents 3 \
  --port "80:80@loadbalancer" \
  --port "443:443@loadbalancer"

# Verify cluster
kubectl cluster-info
kubectl get nodes
```

## Option 3: Minikube (Limited Multi-Node Support)

Minikube primarily supports single-node clusters, but newer versions offer limited multi-node capabilities.

### Installation

```bash
# Install Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Verify installation
minikube version
```

### Create Multi-Node Cluster (Experimental)

```bash
# Start a multi-node cluster (requires Docker driver)
minikube start --nodes 3 --driver=docker

# Verify nodes
kubectl get nodes
```

**Note**: Multi-node support in Minikube is experimental and may have limitations.

## Option 4: K3s (Production-Ready Lightweight)

K3s is a lightweight, production-ready Kubernetes distribution.

### Installation

```bash
# Install K3s server
curl -sfL https://get.k3s.io | sh -

# Get the node token for joining workers
sudo cat /var/lib/rancher/k3s/server/node-token

# Install K3s agent on worker nodes
curl -sfL https://get.k3s.io | K3S_URL=https://server-ip:6443 K3S_TOKEN=node-token sh -
```

## Testing Multi-Node Functionality

### Deploy a Test Application

```bash
# Create a test deployment
kubectl create deployment nginx --image=nginx:latest --replicas=6

# Expose the deployment
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# Check pod distribution across nodes
kubectl get pods -o wide

# Scale the deployment
kubectl scale deployment nginx --replicas=10

# Verify pods are distributed across multiple nodes
kubectl get pods -o wide
```

### Verify Node Affinity and Anti-Affinity

```bash
# Create a deployment with node affinity
cat << EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: node-affinity-demo
spec:
  replicas: 3
  selector:
    matchLabels:
      app: node-affinity-demo
  template:
    metadata:
      labels:
        app: node-affinity-demo
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: kubernetes.io/hostname
                operator: In
                values:
                - multinode-cluster-worker
      containers:
      - name: nginx
        image: nginx:latest
EOF

# Check pod placement
kubectl get pods -o wide -l app=node-affinity-demo
```

## WSL2 Configuration (Windows Users)

For WSL2 users, configure port forwarding to access services:

```bash
# Get WSL2 IP address
WSL_IP=$(hostname -I | awk '{print $1}')

# Create port forwarding script
cat << 'EOF' > ~/setup-multinode-forwarding.sh
#!/bin/bash
WSL_IP=$(hostname -I | awk '{print $1}')

# Forward Kubernetes API server
powershell.exe -Command "netsh interface portproxy add v4tov4 listenport=6443 listenaddress=0.0.0.0 connectport=6443 connectaddress=$WSL_IP"

# Forward HTTP/HTTPS
powershell.exe -Command "netsh interface portproxy add v4tov4 listenport=80 listenaddress=0.0.0.0 connectport=80 connectaddress=$WSL_IP"
powershell.exe -Command "netsh interface portproxy add v4tov4 listenport=443 listenaddress=0.0.0.0 connectport=443 connectaddress=$WSL_IP"

# Forward NodePort range
for port in {30000..30100}; do
    powershell.exe -Command "netsh interface portproxy add v4tov4 listenport=$port listenaddress=0.0.0.0 connectport=$port connectaddress=$WSL_IP"
done

echo "Port forwarding configured for WSL2 IP: $WSL_IP"
EOF

chmod +x ~/setup-multinode-forwarding.sh
~/setup-multinode-forwarding.sh
```

## Performance Optimization

### Resource Allocation

For optimal performance with multi-node clusters:

```bash
# Check resource usage
kubectl top nodes
kubectl top pods --all-namespaces

# Monitor cluster resources
kubectl describe nodes
```

### WSL2 Configuration

Create or edit `.wslconfig` in Windows (`C:\Users\<username>\.wslconfig`):

```ini
[wsl2]
memory=12GB
processors=6
swap=4GB
localhostForwarding=true
```

## Troubleshooting

### Common Issues

#### Cluster Creation Fails
```bash
# Check Docker status
docker info

# Verify available resources
free -h
df -h

# Clean up Docker
docker system prune -a
```

#### Node Communication Issues
```bash
# Check node status
kubectl get nodes
kubectl describe nodes

# Check network connectivity
kubectl get pods -n kube-system
kubectl logs -n kube-system kube-flannel-ds-*
```

#### Port Forwarding Issues
```bash
# Check port forwarding status
powershell.exe -Command "netsh interface portproxy show all"

# Remove conflicting port forwarding
powershell.exe -Command "netsh interface portproxy delete v4tov4 listenport=80"
```

### Node Management

#### Labeling Nodes
```bash
# Add custom labels to nodes
kubectl label node multinode-cluster-worker environment=development
kubectl label node multinode-cluster-worker2 environment=staging

# Verify labels
kubectl get nodes --show-labels
```

#### Node Taints and Tolerations
```bash
# Add taint to a node
kubectl taint nodes multinode-cluster-worker dedicated=development:NoSchedule

# Remove taint
kubectl taint nodes multinode-cluster-worker dedicated-
```

## Comparison of Multi-Node Solutions

| Feature | Kind | K3d | Minikube | K3s |
|---------|------|-----|----------|-----|
| Multi-node support | ✅ Excellent | ✅ Excellent | ⚠️ Limited | ✅ Excellent |
| Resource usage | Medium | Low | High | Low |
| Setup complexity | Low | Low | Medium | Medium |
| Production readiness | Development | Development | Development | Production |
| Community support | Excellent | Good | Excellent | Good |

## Cleanup

To remove your multi-node clusters:

```bash
# Kind clusters
kind delete cluster --all

# K3d clusters
k3d cluster delete --all

# Minikube clusters
minikube delete --all

# K3s
sudo /usr/local/bin/k3s-uninstall.sh
```

## Next Steps

After setting up your multi-node cluster, consider:

1. **Installing monitoring**: Prometheus and Grafana
2. **Setting up logging**: ELK stack or Fluentd
3. **Configuring ingress**: NGINX Ingress Controller
4. **Implementing CI/CD**: ArgoCD or Tekton
5. **Security hardening**: Network policies, RBAC, and Pod Security Standards

This setup provides a robust foundation for testing multi-node Kubernetes scenarios locally.
