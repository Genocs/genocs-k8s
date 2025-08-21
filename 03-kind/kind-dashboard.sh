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