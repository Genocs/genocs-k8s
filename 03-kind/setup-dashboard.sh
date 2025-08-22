#!/bin/bash

# Kubernetes Dashboard Auto-Setup Script for KIND
# This script sets up KIND cluster and Dashboard on Ubuntu 24.10

set -e

# Configuration
CLUSTER_NAME="dashboard-cluster"
DASHBOARD_VERSION="v2.7.0"
SERVICE_NAME="k8s-dashboard"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root (optional - KIND can run as root)
check_root() {
    if [[ $EUID -eq 0 ]]; then
        warn "Running as root - this is acceptable for KIND setup"
    else
        log "Running as non-root user - will use sudo for privileged operations"
    fi
}

# Install dependencies
install_dependencies() {
    log "Installing dependencies..."
    
    # Determine if we need sudo
    if [[ $EUID -eq 0 ]]; then
        SUDO=""
        USER_HOME="/root"
    else
        SUDO="sudo"
        USER_HOME="/home/$USER"
    fi
    
    # Update package list
    $SUDO apt update
    
    # Install Docker if not present
    if ! command -v docker &> /dev/null; then
        log "Installing Docker..."
        $SUDO apt install -y docker.io
        $SUDO systemctl enable docker
        $SUDO systemctl start docker
        if [[ $EUID -ne 0 ]]; then
            $SUDO usermod -aG docker $USER
            log "Docker installed. Please logout and login again to apply group changes."
        fi
    fi
    
    # Install kubectl if not present
    if ! command -v kubectl &> /dev/null; then
        log "Installing kubectl..."
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        $SUDO install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
        rm kubectl
    fi
    
    # Install KIND if not present
    if ! command -v kind &> /dev/null; then
        log "Installing KIND..."
        curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
        chmod +x ./kind
        $SUDO mv ./kind /usr/local/bin/kind
    fi
}

# Create KIND cluster configuration
create_kind_config() {
    log "Creating KIND cluster configuration..."
    
    cat > /tmp/kind-config.yaml <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: ${CLUSTER_NAME}
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 8080
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
  - containerPort: 8443
    hostPort: 8443
    protocol: TCP
- role: worker
- role: worker
- role: worker
EOF
}

# Create and start KIND cluster
setup_kind_cluster() {
    log "Setting up KIND cluster..."
    
    # Check if cluster already exists
    if kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
        warn "Cluster ${CLUSTER_NAME} already exists. Deleting and recreating..."
        kind delete cluster --name ${CLUSTER_NAME}
    fi
    
    # Create cluster
    kind create cluster --config /tmp/kind-config.yaml
    
    # Wait for cluster to be ready
    log "Waiting for cluster to be ready..."
    kubectl wait --for=condition=Ready nodes --all --timeout=300s
}

# Deploy Kubernetes Dashboard
deploy_dashboard() {
    log "Deploying Kubernetes Dashboard..."
    
    # Apply dashboard manifests
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/${DASHBOARD_VERSION}/aio/deploy/recommended.yaml
    
    # Wait for dashboard to be ready
    log "Waiting for dashboard pods to be ready..."
    kubectl wait --for=condition=Ready pod -l k8s-app=kubernetes-dashboard -n kubernetes-dashboard --timeout=300s
}

# Create service account and get token
setup_dashboard_access() {
    log "Setting up dashboard access..."
    
    # Create service account
    kubectl apply -f - <<EOF
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
    
    # Create token secret
    kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
  annotations:
    kubernetes.io/service-account.name: "admin-user"
type: kubernetes.io/service-account-token
EOF
    
    # Wait a moment for token to be generated
    sleep 5
    
    # Get and save token
    TOKEN=$(kubectl get secret admin-user -n kubernetes-dashboard -o jsonpath={".data.token"} | base64 -d)
    echo "$TOKEN" > /tmp/dashboard-token.txt
    
    log "Dashboard token saved to /tmp/dashboard-token.txt"
    echo "Token: $TOKEN"
}

# Create systemd service for auto-start
create_systemd_service() {
    log "Creating systemd service for auto-start..."
    
    # Determine user and home directory
    if [[ $EUID -eq 0 ]]; then
        SERVICE_USER="root"
        SERVICE_HOME="/root"
        SERVICE_GROUP="root"
    else
        SERVICE_USER="$USER"
        SERVICE_HOME="/home/$USER"
        SERVICE_GROUP="docker"
    fi
    
    # Create the service file
    $SUDO tee $SERVICE_FILE > /dev/null <<EOF
[Unit]
Description=Kubernetes Dashboard Auto-Start
After=docker.service
Requires=docker.service
StartLimitIntervalSec=0

[Service]
Type=oneshot
RemainAfterExit=yes
User=$SERVICE_USER
Group=$SERVICE_GROUP
Environment=HOME=$SERVICE_HOME
WorkingDirectory=$SERVICE_HOME
ExecStart=/usr/local/bin/start-k8s-dashboard.sh
ExecStop=/usr/local/bin/stop-k8s-dashboard.sh
TimeoutStartSec=600
Restart=on-failure
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF
    
    # Create start script
    $SUDO tee /usr/local/bin/start-k8s-dashboard.sh > /dev/null <<'EOF'
#!/bin/bash
set -e

CLUSTER_NAME="dashboard-cluster"
USER_HOME="$SERVICE_HOME"

# Wait for Docker to be ready
while ! docker info >/dev/null 2>&1; do
    echo "Waiting for Docker to be ready..."
    sleep 5
done

# Check if cluster exists, if not create it
if ! kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
    echo "Creating KIND cluster..."
    kind create cluster --name ${CLUSTER_NAME}
fi

# Wait for cluster to be ready
echo "Waiting for cluster nodes to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s

# Deploy dashboard if not already deployed
if ! kubectl get namespace kubernetes-dashboard >/dev/null 2>&1; then
    echo "Deploying Kubernetes Dashboard..."
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
    kubectl wait --for=condition=Ready pod -l k8s-app=kubernetes-dashboard -n kubernetes-dashboard --timeout=300s
fi

# Start port forwarding in background
nohup kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard 8443:443 --address=0.0.0.0 >/var/log/dashboard-port-forward.log 2>&1 &
echo $! > /tmp/dashboard-port-forward.pid

echo "Kubernetes Dashboard is ready at https://localhost:8443"
echo "Use token from /tmp/dashboard-token.txt to login"
EOF
    
    # Create stop script
    $SUDO tee /usr/local/bin/stop-k8s-dashboard.sh > /dev/null <<'EOF'
#!/bin/bash

# Kill port forwarding
if [ -f /tmp/dashboard-port-forward.pid ]; then
    kill $(cat /tmp/dashboard-port-forward.pid) 2>/dev/null || true
    rm -f /tmp/dashboard-port-forward.pid
fi

# Remove Windows port forwarding if in WSL2
if [[ -n "${WSL_DISTRO_NAME}" ]]; then
    echo "Removing Windows port forwarding..."
    cat > /tmp/cleanup-port-forward.ps1 <<'PSEOF'
try {
    netsh interface portproxy delete v4tov4 listenport=8443 listenaddress=0.0.0.0
    Write-Host "Port forwarding removed"
} catch {
    Write-Host "No port forwarding to remove"
}

try {
    Remove-NetFirewallRule -DisplayName "WSL2 K8s Dashboard" -ErrorAction SilentlyContinue
    Write-Host "Firewall rule removed"
} catch {}
PSEOF
    
    powershell.exe -ExecutionPolicy Bypass -File /tmp/cleanup-port-forward.ps1 2>/dev/null || true
fi

# Optionally delete the cluster (uncomment if you want to clean up completely)
# kind delete cluster --name dashboard-cluster
EOF
    
    # Make scripts executable
    $SUDO chmod +x /usr/local/bin/start-k8s-dashboard.sh
    $SUDO chmod +x /usr/local/bin/stop-k8s-dashboard.sh
    
    # Enable and start service
    $SUDO systemctl daemon-reload
    $SUDO systemctl enable $SERVICE_NAME
    
    log "Systemd service created and enabled"
}

# Main execution
main() {
    log "Starting Kubernetes Dashboard setup for KIND..."
    
    check_root
    install_dependencies
    create_kind_config
    setup_kind_cluster
    deploy_dashboard
    setup_dashboard_access
    create_systemd_service
    
    log "Setup completed successfully!"
    log ""
    log "=== WSL2 Configuration ==="
    log "Dashboard will automatically start on VM boot"
    log "Access from Windows: https://localhost:8443"
    log "Access from WSL2: https://localhost:8443"
    log ""
    log "Manual controls:"
    log "  Start:  $SUDO systemctl start $SERVICE_NAME"
    log "  Stop:   $SUDO systemctl stop $SERVICE_NAME"
    log "  Status: $SUDO systemctl status $SERVICE_NAME"
    log ""
    log "Token file: /tmp/dashboard-token.txt"
    log ""
    log "=== WSL2 Specific Notes ==="
    log "• Port forwarding to Windows is automatic"
    log "• Windows Firewall rule added for port 8443"
    log "• If port forwarding fails, run manually:"
    log "  powershell.exe 'netsh interface portproxy add v4tov4 listenport=8443 listenaddress=0.0.0.0 connectport=8443 connectaddress=\$(wsl hostname -I).Trim()'"
    log ""
    log "To access the dashboard now, run:"
    log "  $SUDO systemctl start $SERVICE_NAME"
}

# Run main function
main "$@"