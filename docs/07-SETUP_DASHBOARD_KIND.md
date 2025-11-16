# Setting Up Kubernetes Dashboard with Kind

This guide provides step-by-step instructions for setting up the Kubernetes Dashboard in your Kind cluster with automatic startup capabilities.

## Overview

The Kubernetes Dashboard provides a web-based user interface for managing your cluster. This setup includes:

- Dashboard deployment in Kind cluster
- Service account with appropriate permissions
- External accessibility from Windows host
- Persistent configuration across cluster restarts

## Prerequisites

- Kind cluster installed and running
- kubectl configured to work with your Kind cluster
- WSL2 environment configured
- Administrative access to both WSL2 and Windows

## Step 1: Deploy Kubernetes Dashboard

Deploy the official Kubernetes Dashboard to your Kind cluster:

```bash
# Apply the dashboard manifests
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

# Verify the deployment
kubectl get pods -n kubernetes-dashboard
```

## Step 2: Create Service Account and RBAC

Create a service account with appropriate permissions for dashboard access:

```bash
# Create the service account and cluster role binding
cat <<EOF | kubectl apply -f -
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
```

## Step 3: Create Dashboard Access Script

Create a script to start the dashboard proxy and set up port forwarding:

```bash
# Create the dashboard access script
cat <<'EOF' > ~/kind-dashboard.sh
#!/bin/bash

# Function to get Kind cluster IP
get_kind_ip() {
    # Get the Kind cluster IP from docker network
    KIND_IP=$(docker network inspect kind | jq -r '.[0].IPAM.Config[0].Gateway' 2>/dev/null)
    if [ -z "$KIND_IP" ] || [ "$KIND_IP" = "null" ]; then
        # Fallback: get IP from kubectl
        KIND_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
    fi
    echo $KIND_IP
}

# Function to setup port forwarding
setup_port_forward() {
    local KIND_IP=$1

    # Remove existing port forwarding if any
    powershell.exe -Command "netsh interface portproxy delete v4tov4 listenport=10443" 2>/dev/null

    # Add new port forwarding
    powershell.exe -Command "netsh interface portproxy add v4tov4 listenport=10443 listenaddress=0.0.0.0 connectport=10443 connectaddress=$KIND_IP"

    echo "Port forwarding configured: localhost:10443 -> $KIND_IP:10443"
}

# Main execution
echo "Starting Kind Dashboard setup..."

# Wait for dashboard to be ready
echo "Waiting for dashboard pods to be ready..."
kubectl wait --for=condition=ready pod -l k8s-app=kubernetes-dashboard -n kubernetes-dashboard --timeout=300s

# Get Kind cluster IP
KIND_IP=$(get_kind_ip)
echo "Kind cluster IP: $KIND_IP"

# Setup port forwarding
setup_port_forward $KIND_IP

# Start kubectl proxy in background
echo "Starting kubectl proxy..."
kubectl proxy --port=10443 --address=0.0.0.0 --accept-hosts='.*' &
PROXY_PID=$!

# Save PID for cleanup
echo $PROXY_PID > ~/.kind-dashboard-pid

echo "Dashboard is now accessible at: https://localhost:10443"
echo "Press Ctrl+C to stop the proxy"

# Wait for interrupt
trap "echo 'Stopping dashboard proxy...'; kill $PROXY_PID; rm -f ~/.kind-dashboard-pid; exit" INT
wait $PROXY_PID
EOF

# Make the script executable
chmod +x ~/kind-dashboard.sh
```

## Step 4: Create Systemd Service (Optional)

If you want the dashboard to start automatically, create a systemd service:

### Option 1: Use the provided script (Recommended)

```bash
# Make the script executable
chmod +x 03-kind/create-kind-dashboard-service.sh

# Run the script to create the service file
./03-kind/create-kind-dashboard-service.sh

# Enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable kind-dashboard.service
sudo systemctl start kind-dashboard.service
```

### Option 2: Manual creation

If you prefer to create the service manually, replace `$USER` and `$HOME` with actual values:

```bash
# Get your username and home directory
CURRENT_USER=$(whoami)
USER_HOME=$(eval echo ~$CURRENT_USER)

# Create the service file
sudo tee /etc/systemd/system/kind-dashboard.service > /dev/null <<EOF
[Unit]
Description=Kind Kubernetes Dashboard Service
After=network.target
Wants=network.target

[Service]
Type=simple
User=$CURRENT_USER
WorkingDirectory=$USER_HOME
ExecStart=$USER_HOME/kind-dashboard.sh
Restart=always
RestartSec=10
Environment=KUBECONFIG=$USER_HOME/.kube/config

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable kind-dashboard.service
sudo systemctl start kind-dashboard.service
```

## Step 5: Access the Dashboard

### Method 1: Using the Script (Recommended)

```bash
# Run the dashboard script
~/kind-dashboard.sh
```

### Method 2: Manual Access

```bash
# Start kubectl proxy
kubectl proxy --port=10443 --address=0.0.0.0 --accept-hosts='.*'

# In another terminal, setup port forwarding
KIND_IP=$(docker network inspect kind | jq -r '.[0].IPAM.Config[0].Gateway')
powershell.exe -Command "netsh interface portproxy add v4tov4 listenport=10443 listenaddress=0.0.0.0 connectport=10443 connectaddress=$KIND_IP"
```

## Step 6: Generate Authentication Token

Generate a token for dashboard authentication:

```bash
# Create a token for the admin user
kubectl create token admin-user -n kubernetes-dashboard
```

## Step 7: Access the Dashboard

1. Open your web browser and navigate to: [https://localhost:10443](https://localhost:10443)

2. You'll be redirected to: [https://localhost:10443/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/](https://localhost:10443/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/)

3. Paste the generated token from Step 6 into the dashboard login page.

## Verification

After completing the setup, verify that:

- Dashboard pods are running: `kubectl get pods -n kubernetes-dashboard`
- Service account exists: `kubectl get serviceaccount admin-user -n kubernetes-dashboard`
- Port forwarding is active: `netsh interface portproxy show all`
- Dashboard is accessible at [https://localhost:10443](https://localhost:10443)

## Troubleshooting

### Dashboard Pods Not Ready

```bash
# Check pod status
kubectl get pods -n kubernetes-dashboard

# Check pod logs
kubectl logs -n kubernetes-dashboard -l k8s-app=kubernetes-dashboard

# Check events
kubectl get events -n kubernetes-dashboard
```

### Port Forwarding Issues

```bash
# Remove existing port forwarding
powershell.exe -Command "netsh interface portproxy delete v4tov4 listenport=10443"

# Check current port forwarding rules
netsh interface portproxy show all
```

### Token Issues

```bash
# Delete and recreate the service account
kubectl delete serviceaccount admin-user -n kubernetes-dashboard
kubectl delete clusterrolebinding admin-user

# Recreate using the commands from Step 2
```

### Kind Cluster Issues

```bash
# Check Kind cluster status
kind get clusters
kind get nodes

# Restart Kind cluster if needed
kind delete cluster
kind create cluster
```

### Systemd Service Issues

If you encounter issues with the systemd service:

```bash
# Check service status
sudo systemctl status kind-dashboard.service

# Check service logs
sudo journalctl -u kind-dashboard.service -f

# Verify the service file syntax
sudo systemd-analyze verify /etc/systemd/system/kind-dashboard.service

# Check if the script exists and is executable
ls -la ~/kind-dashboard.sh

# Recreate the service file using the script
./03-kind/create-kind-dashboard-service.sh
```

## Cleanup

To stop the dashboard:

```bash
# If using the script, press Ctrl+C
# If using systemd service
sudo systemctl stop kind-dashboard.service

# Remove port forwarding
powershell.exe -Command "netsh interface portproxy delete v4tov4 listenport=10443"

# Kill any remaining proxy processes
pkill -f "kubectl proxy"
```

## Features

With this configuration, your Kubernetes Dashboard will:

- ✅ Deploy automatically in your Kind cluster
- ✅ Provide secure access with token-based authentication
- ✅ Be accessible from your Windows host at [https://localhost:10443](https://localhost:10443)
- ✅ Support automatic restart via systemd (optional)
- ✅ Work seamlessly with Kind cluster lifecycle
