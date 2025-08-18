# Kubernetes Cluster Setup with MicroK8s on Ubuntu

## Prerequisites

Before you begin, ensure you have the following prerequisites:

- **Ubuntu WSL2 VM**: Ensure you have a working Ubuntu instance.

1. First, install MicroK8s on your Ubuntu system:

   ```bash
   sudo snap install microk8s --classic
   ```

2. Add your user to the microk8s group to avoid using sudo with every command

   ```bash
   sudo usermod -a -G microk8s $USER
   sudo chown -f -R $USER ~/.kube
   ```

3. Start MicroK8s and wait for it to be ready

   ```bash
   # Start Microk8s
   microk8s start

   # Check status
   microk8s status --wait-ready
   ```

4. Enable essential addons for your cluster:

   ```bash
   microk8s enable metallb       # For load balancing
   microk8s enable ingress       # For ingress controller
   microk8s enable dns           # For DNS resolution
   microk8s enable cert-manager  # For SSL/TLS certificate management
   ```

5. Enable community addons and other essential services:

   ```bash
   microk8s enable community     # For community addons
   ```

6. Check community addons is enabled. By running microk8s status you can see the status of all addons:

   ```bash
   microk8s status               # To check the status of all addons
   ```

7. Enable ArgoCD for continuous deployment (ArgoCD is available in the community addons):

   ```bash
   microk8s enable argocd        # For continuous deployment
   ```

8. Run Kubernetes dashboard (Use a new terminal for this command):

   ```bash
   # Access the dashboard
   microk8s dashboard-proxy
   ```

9. To verify your installation, you can run these commands:

   ```bash
   # Check cluster status
   microk8s kubectl get nodes

   # Check all resources
   microk8s kubectl get all --all-namespaces

   # Create a test deployment by means of an Nginx image
   # This will create a simple Nginx deployment
   microk8s kubectl create deployment nginx --image=nginx
   ```

10. To stop MicroK8s when needed:

    ```bash
    # Stop Microk8s
    microk8s stop
    ```

11. For WSL2 specific configuration, you'll need to set up port forwarding from Windows to WSL2. You can do this in PowerShell with either of these methods:

    ```PowerShell
    ## Forward WSL2 IP connections to Windows host

    ### Option 1
    wsl hostname -I
    netsh interface portproxy add v4tov4 listenport=80 listenaddress=0.0.0.0 connectport=80 connectaddress=<WSL2_IP>

    ### Option 2
    netsh interface portproxy set v4tov4 listenport=80 listenaddress=0.0.0.0 connectport=80 connectaddress=$(wsl hostname -I)
    ```

**Important Notes**

> - Make sure your WSL2 VM has enough resources allocated (memory and CPU)
> - The default configuration creates a single-node cluster
> - You can use `microk8s kubectl` instead of `kubectl` for all Kubernetes commands
> - For development purposes, you might want to create an alias: `alias kubectl='microk8s kubectl'`
