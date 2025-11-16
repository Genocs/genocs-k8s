# Setting Up Kubernetes Dashboard

This guide provides step-by-step instructions for setting up the Kubernetes Dashboard in your MicroK8s cluster with automatic startup capabilities.

## Overview

The Kubernetes Dashboard provides a web-based user interface for managing your cluster. This setup includes:

- Automatic dashboard startup when MicroK8s starts
- Automatic restart on failure
- External accessibility from Windows host
- Persistent configuration across WSL2 restarts

## Prerequisites

- MicroK8s installed and running
- WSL2 environment configured
- Administrative access to both WSL2 and Windows

## Step 1: Create Systemd Service

Create a systemd service file to enable automatic dashboard startup. This service will start the dashboard proxy when MicroK8s initializes.

1. Create the service file at `/etc/systemd/system/microk8s-dashboard.service`:

```ini
[Unit]
Description=MicroK8s Dashboard Service
After=snap.microk8s.daemon-kubelite.service
Requires=snap.microk8s.daemon-kubelite.service

[Service]
Type=simple
User=root
ExecStart=/snap/bin/microk8s dashboard-proxy
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

## Step 2: Enable and Start the Service

Enable the service to start automatically and verify it's running:

```bash
# Reload systemd configuration
sudo systemctl daemon-reload

# Enable the service for automatic startup
sudo systemctl enable microk8s-dashboard.service

# Start the service
sudo systemctl start microk8s-dashboard.service

# Verify service status
sudo systemctl status microk8s-dashboard.service
```

## Step 3: Configure External Access

To access the dashboard from your Windows host, set up port forwarding:

1. Get your WSL2 IP address:

```bash
WSL_IP=$(wsl hostname -I)
```

2. Configure port forwarding in Windows PowerShell:

```powershell
netsh interface portproxy add v4tov4 listenport=10443 listenaddress=0.0.0.0 connectport=10443 connectaddress=$WSL_IP
```

## Step 4: Create Persistent Port Forwarding

To maintain port forwarding across WSL2 restarts, create a startup script:

1. Create a startup script at `~/.wslconfig`:

```bash
#!/bin/bash
# Wait for network initialization
sleep 10

# Get WSL2 IP address
WSL_IP=$(hostname -I | awk '{print $1}')

# Configure port forwarding
powershell.exe -Command "netsh interface portproxy add v4tov4 listenport=10443 listenaddress=0.0.0.0 connectport=10443 connectaddress=$WSL_IP"
```

2. Make the script executable and add it to your shell startup:

```bash
chmod +x ~/.wslconfig
echo "~/.wslconfig" >> ~/.bashrc
```

## Step 5: Access the Dashboard

1. Open your web browser and navigate to: [https://localhost:10443](https://localhost:10443)

2. Generate an authentication token:

```bash
microk8s kubectl create token default -n kube-system
```

3. Copy the generated token and paste it into the dashboard login page.

## Verification

After completing the setup, verify that:

- The dashboard service is running: `sudo systemctl status microk8s-dashboard.service`
- Port forwarding is active: `netsh interface portproxy show all`
- Dashboard is accessible at [https://localhost:10443](https://localhost:10443)

## Troubleshooting

### Service Not Starting

- Check service logs: `sudo journalctl -u microk8s-dashboard.service`
- Verify MicroK8s is running: `microk8s status`

### Port Forwarding Issues

- Remove existing port forwarding: `netsh interface portproxy delete v4tov4 listenport=10443`
- Recreate port forwarding with the correct WSL2 IP address

### Dashboard Not Accessible

- Verify the dashboard proxy is running: `microk8s dashboard-proxy --help`
- Check firewall settings on Windows host
- Ensure port 10443 is not blocked by antivirus software

## Features

With this configuration, your Kubernetes Dashboard will:

- ✅ Start automatically when MicroK8s initializes
- ✅ Restart automatically if the service fails
- ✅ Be accessible from your Windows host at [https://localhost:10443](https://localhost:10443)
- ✅ Maintain configuration across WSL2 restarts
- ✅ Provide secure access with token-based authentication
