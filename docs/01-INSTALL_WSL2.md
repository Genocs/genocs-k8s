# Install WSL2

This guide provides step-by-step instructions for installing Windows Subsystem for Linux 2 (WSL2) on Windows.

## Prerequisites

- Windows 10 version 2004 or later (Build 19041 or higher)
- Virtualization enabled in BIOS/UEFI
- Windows Subsystem for Linux feature enabled

## Installation Methods

There are two primary methods to install WSL2:

### Method 1: Install Ubuntu from Microsoft Store

1. **Open Microsoft Store**:
   - Launch Microsoft Store from the Start menu
   - Search for "Ubuntu"

   ![Open Microsoft Store](../assets/k8s_01.png)

2. **Select Ubuntu Distribution**:
   - Choose your preferred Ubuntu version (e.g., Ubuntu 24.04 LTS)
   - Click "Get" to download and install

   ![Select Distro](../assets/k8s_02.png)

3. **Launch and Configure**:
   - After installation, launch Ubuntu from the Start menu
   - Create a username and password when prompted

### Method 2: Install WSL2 via Command Line

1. **Set WSL2 as Default Version**:
   Open PowerShell as Administrator and run:

   ```powershell
   wsl --set-default-version 2
   ```

2. **Install Ubuntu**:
   ```powershell
   wsl --install -d Ubuntu
   ```

3. **Install Specific Ubuntu Version** (Optional):
   ```powershell
   wsl --install -d Ubuntu-24.04
   ```

4. **Verify Installation**:
   ```bash
   wsl --list --all --verbose
   ```

   Expected output:
   ```plaintext
     NAME                   STATE           VERSION
   * Ubuntu-24.04           Running         2
   ```

5. **Check Default Distribution**:
   ```bash
   wsl --status
   ```

   Expected output:
   ```plaintext
   Default Distribution: Ubuntu-24.04
   Default Version: 2
   ```

6. **Set Default Distribution** (if needed):
   ```bash
   wsl --set-default Ubuntu-24.04
   ```

## Configure Ubuntu and Enable systemd

After installation, configure Ubuntu and enable systemd support:

1. **Launch Ubuntu**:
   - Open Ubuntu from the Start menu, or
   - Type `wsl` in PowerShell or Command Prompt

2. **Verify Ubuntu Version**:
   ```bash
   lsb_release -a
   ```

   Expected output:
   ```plaintext
   No LSB modules are available.
   Distributor ID: Ubuntu
   Description:    Ubuntu 24.04.2 LTS
   Release:        24.04
   Codename:       noble
   ```

3. **Complete Initial Setup**:
   - Create a username and password when prompted
   - Update the system packages:
     ```bash
     sudo apt update && sudo apt upgrade -y
     ```

4. **Enable systemd Support**:
   ```bash
   sudo nano /etc/wsl.conf
   ```

   Add the following configuration to the file:
   ```ini
   [boot]
   systemd=true
   #[network]
   #generateResolvConf=false
   ```

   **Note**: If the file doesn't exist, it will be created. If it contains existing content, add the new lines without removing existing configurations.

5. **Restart WSL2**:
   ```bash
   wsl --shutdown
   wsl
   ```

## Install Additional Components

### Install Snapd

Install the snap package manager for Ubuntu:

```bash
sudo apt update
sudo apt install snapd -y
```

### Configure IP Forwarding (Optional)

If you need to configure network forwarding for your Kubernetes setup:

```bash
# Install required networking tools
sudo apt install net-tools iptables -y

# Verify iptables installation
iptables --version

# Check current iptables rules
iptables -L

# Check NAT table rules
iptables -t nat -L

# Enable IP forwarding
sudo sysctl net.ipv4.ip_forward=1

# Make IP forwarding persistent
echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf

# Configure port forwarding (replace with your specific requirements)
# Example: Forward port 5101 to destination port 80
# iptables -t nat -A PREROUTING -p tcp --dport 5101 -j DNAT --to-destination <destination-ip>:80

# Enable masquerading for outbound traffic
sudo iptables -t nat -A POSTROUTING ! -s 127.0.0.1 -j MASQUERADE

# Save iptables rules (Ubuntu)
sudo netfilter-persistent save
```

## Verification

Verify that WSL2 is properly installed and configured:

```bash
# Check WSL version
wsl --version

# Check running distributions
wsl --list --running

# Test systemd functionality
systemctl --version
```

## Troubleshooting

### Common Issues:

1. **WSL2 not available**:
   - Ensure Windows 10 version 2004 or later
   - Enable virtualization in BIOS/UEFI
   - Enable Windows Subsystem for Linux feature

2. **systemd not working**:
   - Verify `/etc/wsl.conf` configuration
   - Restart WSL2 completely
   - Check Windows updates

3. **Network connectivity issues**:
   - Restart WSL2: `wsl --shutdown`
   - Check Windows firewall settings
   - Verify network adapter configuration

### Enable Windows Features:

If WSL2 is not available, enable required Windows features:

```powershell
# Enable Windows Subsystem for Linux
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

# Enable Virtual Machine feature
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Restart computer after enabling features
```

## Next Steps

After successfully installing WSL2, you can:

1. Install a Kubernetes distribution (Minikube, Kind, or MicroK8s)
2. Set up development tools and SDKs
3. Configure your development environment
4. Proceed with Kubernetes cluster setup

## References

- [Microsoft WSL2 Installation Guide](https://docs.microsoft.com/en-us/windows/wsl/install)
- [WSL2 Command Reference](https://docs.microsoft.com/en-us/windows/wsl/basic-commands)
- [WSL2 Configuration](https://docs.microsoft.com/en-us/windows/wsl/wsl-config)
- [Ubuntu on WSL2](https://ubuntu.com/wsl)
