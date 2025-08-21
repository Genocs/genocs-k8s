#!/bin/bash

# Script to create Kind Dashboard systemd service
# This script will create a proper systemd service file with correct paths

# Get current user and home directory
CURRENT_USER=$(whoami)
USER_HOME=$(eval echo ~$CURRENT_USER)

echo "Creating Kind Dashboard systemd service for user: $CURRENT_USER"
echo "Home directory: $USER_HOME"

# Create the systemd service file
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

echo "Systemd service file created successfully!"
echo ""
echo "To enable and start the service, run:"
echo "sudo systemctl daemon-reload"
echo "sudo systemctl enable kind-dashboard.service"
echo "sudo systemctl start kind-dashboard.service"
echo ""
echo "To check the service status:"
echo "sudo systemctl status kind-dashboard.service"
