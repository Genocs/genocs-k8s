# Kubernetes Dashboard Setup for KIND
I'm solution architect and I'm setup a K8s cluster on a Ubuntu 24.10 VM by using KIND. I'd like to setup the Dashboard to run whenever the VM is spin up. Can you prepare a solution for that?

## Solution


I'll help you set up a Kubernetes Dashboard that automatically starts when your Ubuntu VM boots up. Here's a comprehensive solution using KIND:I've created a comprehensive solution for automatically setting up the Kubernetes Dashboard with KIND on your Ubuntu 24.10 VM. Here's what the script does:

## Key Features:

1. **Auto-Installation**: Installs Docker, kubectl, and KIND if not present
2. **KIND Cluster Setup**: Creates a cluster with proper port mappings
3. **Dashboard Deployment**: Deploys the latest Kubernetes Dashboard
4. **Access Setup**: Creates admin service account and token
5. **Auto-Start Service**: Creates a systemd service for automatic startup

## Usage:

1. **Save the script** to your VM (e.g., as `setup-dashboard.sh`)
2. **Make it executable**: `chmod +x setup-dashboard.sh`
3. **Run the setup**: `./setup-dashboard.sh`

## What happens after setup:

- The dashboard will automatically start when the VM boots
- Access it at `https://localhost:8443`
- Use the token from `/tmp/dashboard-token.txt` to login
- The service ensures the cluster and dashboard are ready before exposing the port

## Manual Controls:

```bash
# Start dashboard manually
sudo systemctl start k8s-dashboard

# Stop dashboard
sudo systemctl stop k8s-dashboard

# Check status
sudo systemctl status k8s-dashboard

# View logs
journalctl -u k8s-dashboard -f
```

## Important Notes:

1. **User Groups**: After initial setup, you may need to logout/login for Docker group changes
2. **Firewall**: If accessing remotely, ensure port 8443 is open
3. **Token Security**: The admin token provides full cluster access - keep it secure
4. **Resource Usage**: The service waits for dependencies and has timeouts to handle slow starts

The solution is robust and handles edge cases like Docker not being ready, cluster recreation, and service failures with automatic restarts. Would you like me to modify any part of this setup or add additional features?

---
## Question

The VM I've used is a windows WSL2 Linux VM, how can forward the port to be access from the windows host?

## Solution

Great point! Since you're using WSL2, you'll need to handle port forwarding from WSL2 to the Windows host. Let me update the solution to work properly with WSL2:Perfect! I've updated the solution to work seamlessly with WSL2. Here are the key changes for WSL2 compatibility:

## WSL2-Specific Features Added:

### 1. **Automatic Windows Port Forwarding**
- Detects WSL2 environment automatically
- Uses `netsh` to create port proxy from Windows to WSL2
- Maps Windows `localhost:8443` → WSL2 `<wsl-ip>:8443`

### 2. **Windows Firewall Configuration**
- Automatically adds Windows Firewall rule for port 8443
- Allows inbound connections to the dashboard

### 3. **Proper Cleanup**
- Removes port forwarding rules when stopping the service
- Cleans up firewall rules

## How to Use:

1. **Run the setup script** in your WSL2 Ubuntu terminal
2. **Access from Windows** at `https://localhost:8443`
3. **Use the token** from `/tmp/dashboard-token.txt` to login

## Access Points:

- **From Windows**: `https://localhost:8443` 
- **From WSL2**: `https://localhost:8443`
- **From other machines on network**: `https://<windows-ip>:8443`

## Manual Port Forwarding (if needed):

If the automatic setup fails, you can manually configure port forwarding from a Windows PowerShell (as Administrator):

```powershell
# Get WSL2 IP
$wslIP = wsl hostname -I
$wslIP = $wslIP.Trim()

# Add port forwarding
netsh interface portproxy add v4tov4 listenport=8443 listenaddress=0.0.0.0 connectport=8443 connectaddress=$wslIP

# Add firewall rule
New-NetFirewallRule -DisplayName "WSL2 K8s Dashboard" -Direction Inbound -LocalPort 8443 -Protocol TCP -Action Allow
```

## Troubleshooting:

```bash
# Check if port forwarding is working from WSL2
curl -k https://localhost:8443

# View service logs
journalctl -u k8s-dashboard -f

# Check Windows port proxy rules
powershell.exe "netsh interface portproxy show v4tov4"
```

The solution now automatically handles all WSL2 networking complexities, making the dashboard accessible from your Windows host browser seamlessly!