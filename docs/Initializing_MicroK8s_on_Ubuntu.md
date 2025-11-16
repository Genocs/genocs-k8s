# Initializing MicroK8s on Ubuntu WSL2
_Exported on 5/19/2025 at 23:40:37 GMT+2 from Cursor (0.50.5)_

---

**User**

describe how to initialize microk8s on ubuntu WSL2 VM

---

**Cursor**

I'll help you describe how to initialize MicroK8s on an Ubuntu WSL2 VM. Let me first check the existing documentation and then provide a comprehensive guide.

Let me search for any additional relevant information in the codebase.



Based on the search results and the README.md content, I'll provide a comprehensive guide on how to initialize MicroK8s on an Ubuntu WSL2 VM. Here's the step-by-step process:

1. First, install MicroK8s on your Ubuntu WSL2 VM:
```bash
sudo snap install microk8s --classic
```

2. Add your user to the microk8s group to avoid using sudo with every command:
```bash
sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube
```

3. Start MicroK8s and wait for it to be ready:
```bash
microk8s start
microk8s status --wait-ready
```

4. Enable essential addons for your cluster:
```bash
microk8s enable metallb    # For load balancing
microk8s enable ingress    # For ingress controller
microk8s enable dns        # For DNS resolution
microk8s enable cert-manager  # For SSL/TLS certificate management
```

5. To access the Kubernetes dashboard:
```bash
microk8s dashboard-proxy
```

6. For WSL2 specific configuration, you'll need to set up port forwarding from Windows to WSL2. You can do this in PowerShell with either of these methods:

Option 1:
```powershell
wsl hostname -I
netsh interface portproxy add v4tov4 listenport=80 listenaddress=0.0.0.0 connectport=80 connectaddress=<WSL2_IP>
```

Option 2:
```powershell
netsh interface portproxy set v4tov4 listenport=80 listenaddress=0.0.0.0 connectport=80 connectaddress=$(wsl hostname -I)
```

7. To verify your installation, you can run these commands:
```bash
# Check cluster status
microk8s kubectl get nodes

# Check all resources
microk8s kubectl get all --all-namespaces

# Create a test deployment
microk8s kubectl create deployment nginx --image=nginx
```

8. To stop MicroK8s when needed:
```bash
microk8s stop
```

Important Notes:
- Make sure your WSL2 VM has enough resources allocated (memory and CPU)
- The default configuration creates a single-node cluster
- You can use `microk8s kubectl` instead of `kubectl` for all Kubernetes commands
- For development purposes, you might want to create an alias: `alias kubectl='microk8s kubectl'`

Would you like me to provide more specific details about any of these steps or explain how to configure specific aspects of your MicroK8s cluster?

```shellscript
sudo snap install microk8s --classic
```

```shellscript
sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube
```

```shellscript
microk8s start
microk8s status --wait-ready
```

```shellscript
microk8s enable metallb    # For load balancing
microk8s enable ingress    # For ingress controller
microk8s enable dns        # For DNS resolution
microk8s enable cert-manager  # For SSL/TLS certificate management
```

```shellscript
microk8s dashboard-proxy
```

```powershell
wsl hostname -I
netsh interface portproxy add v4tov4 listenport=80 listenaddress=0.0.0.0 connectport=80 connectaddress=<WSL2_IP>
```

```powershell
netsh interface portproxy set v4tov4 listenport=80 listenaddress=0.0.0.0 connectport=80 connectaddress=$(wsl hostname -I)
```

```shellscript
# Check cluster status
microk8s kubectl get nodes

# Check all resources
microk8s kubectl get all --all-namespaces

# Create a test deployment
microk8s kubectl create deployment nginx --image=nginx
```

```shellscript
microk8s stop
```

---

**User**

add Genocs-library-gnx-architecture.draw.io image into the document

---

**Cursor**

I'll help you add the architecture diagram to the README.md file. First, let me check if the image exists in the assets directory.


Great! I can see the architecture diagram exists in the assets directory. Now I'll edit the README.md file to properly include the image.


```markdown
## Introduction

![Genocs Library Architecture](./assets/Genocs-Library-gnx-architecture.drawio.png)

The repository contains the solution for the Genocs Library K8s challenge. The solution is based on the following requirements:
// ... existing code ...
```

I've updated the README.md file to properly include the architecture diagram. The changes made:

1. Removed the incorrect syntax `[!Architecture]`
2. Added proper Markdown image syntax with a descriptive alt text
3. Maintained the correct path to the image file

The image should now be properly displayed in the README.md file. The architecture diagram will help readers better understand the system's structure and components. Is there anything else you'd like me to help you with?

---

**User**

how to setup microk8s to run dashboard at ckuster startup

---

**Cursor**

I'll help you set up MicroK8s to automatically start the dashboard when the cluster starts. Let me search for any existing dashboard configuration in the codebase first.


To set up MicroK8s to automatically start the dashboard when the cluster starts, we need to create a systemd service. Here's how to do it:

1. First, let's create a systemd service file for the dashboard:


I apologize for trying to execute a command directly. Let me provide you with the complete instructions to set up the dashboard to start automatically:

1. Create a systemd service file for the dashboard. Create a new file at `/etc/systemd/system/microk8s-dashboard.service` with the following content:

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

2. Enable and start the service:
```bash
sudo systemctl daemon-reload
sudo systemctl enable microk8s-dashboard.service
sudo systemctl start microk8s-dashboard.service
```

3. Verify the service is running:
```bash
sudo systemctl status microk8s-dashboard.service
```

4. To make the dashboard accessible from outside the cluster, you'll need to set up port forwarding. Add this to your WSL2 startup script or run it manually:

```bash
# Get the WSL2 IP address
WSL_IP=$(wsl hostname -I)

# Set up port forwarding in Windows PowerShell
netsh interface portproxy add v4tov4 listenport=10443 listenaddress=0.0.0.0 connectport=10443 connectaddress=$WSL_IP
```

5. To make the port forwarding persistent across WSL2 restarts, you can create a startup script in your WSL2 environment. Create a file at `~/.wslconfig` with:

```bash
#!/bin/bash
# Wait for network to be ready
sleep 10

# Get WSL2 IP
WSL_IP=$(hostname -I | awk '{print $1}')

# Set up port forwarding
powershell.exe -Command "netsh interface portproxy add v4tov4 listenport=10443 listenaddress=0.0.0.0 connectport=10443 connectaddress=$WSL_IP"
```

6. Make the script executable and add it to your `.bashrc`:
```bash
chmod +x ~/.wslconfig
echo "~/.wslconfig" >> ~/.bashrc
```

Now the dashboard will:
- Start automatically when MicroK8s starts
- Restart automatically if it crashes
- Be accessible at `https://localhost:10443` from your Windows host
- Persist across WSL2 restarts

To access the dashboard:
1. Open your browser and navigate to `https://localhost:10443`
2. You'll need to get the token for authentication:
```bash
microk8s kubectl create token default -n kube-system
```

Would you like me to explain any part of this setup in more detail?

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

```shellscript
sudo systemctl daemon-reload
sudo systemctl enable microk8s-dashboard.service
sudo systemctl start microk8s-dashboard.service
```

```shellscript
sudo systemctl status microk8s-dashboard.service
```

```shellscript
# Get the WSL2 IP address
WSL_IP=$(wsl hostname -I)

# Set up port forwarding in Windows PowerShell
netsh interface portproxy add v4tov4 listenport=10443 listenaddress=0.0.0.0 connectport=10443 connectaddress=$WSL_IP
```

```shellscript
#!/bin/bash
# Wait for network to be ready
sleep 10

# Get WSL2 IP
WSL_IP=$(hostname -I | awk '{print $1}')

# Set up port forwarding
powershell.exe -Command "netsh interface portproxy add v4tov4 listenport=10443 listenaddress=0.0.0.0 connectport=10443 connectaddress=$WSL_IP"
```

```shellscript
chmod +x ~/.wslconfig
echo "~/.wslconfig" >> ~/.bashrc
```

```shellscript
microk8s kubectl create token default -n kube-system
```

