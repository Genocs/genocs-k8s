# Genocs Library K8s walkthrough

This repository contains Genocs K8s challenge, which involves setting up a Kubernetes cluster.

The solution is designed to be run on an Ubuntu 24.04.1 LTS VM using Windows Subsystem for Linux (WSL2).
The solution can be used on bare Linux or on a VM running on a cloud provider like AWS, Azure, or GCP.

# Genocs Library K8s Challenge

you can setup the cluster by using different methods, like using MicroK8s, Minikube, or any other Kubernetes distribution. The solution is based on the Genocs Library, which provides a set of tools and libraries to build and deploy applications on Kubernetes.

The walkthrough includes setting up helm and ArgoCD for managing the application deployment.


 using MicroK8s, deploying a web application, and managing it with Helm and ArgoCD. The solution also includes the use of an internal API gateway along with a set of other services as: identity service. 
Setup of other resources are also in place as external MongoDB database, RabbitMQ message broker, Nginx AGIC for ingress, an a bunch of Kubernetes resources like Secrets and ConfigMaps and so on.

 It leverages MicroK8s for Kubernetes management and follows best practices for application deployment and management in a Kubernetes environment.

## Introduction

![Genocs Library Architecture](./assets/Genocs-Library-gnx-architecture.drawio.png)

The solution is based on the following requirements:

- Setup windows subsystem for Linux (WSL2) with Ubuntu 24.04.1 LTS
- Use MicroK8s to create a Kubernetes cluster
- Create a Kubernetes cluster with 1 nodes onto Ubuntu Ubuntu 24.04.1 LTS VM
- Use Ngnix AGIC to expose the web application to the internet
- Use Genocs Library to build the services
- Deploy an application based on Genocs Library 
- Use Helm chart to define the application deployment
- Use ArgoCD to manage the application deployment
- Use an internal API gateway to route the traffic to the web services
- Use an internal identity service to manage the user authentication
- Connect to an external MongoDB database
- Connect to an external RabbitMQ message broker 
- Use a Secret to store the database credentials
- Use a ConfigMap to store the web application configuration
- Use a Persistent Volume to store the data
- Use a Persistent Volume Claim to claim the Persistent Volume
- Setup a Kubernetes dashboard to monitor the cluster
- Setup a Kubernetes dashboard to start automatically when the cluster starts
- Setup ArgoCD to manage the application deployment
- Use Helm chart to install MongoDB and RabbitMQ
- Setup AGIC to espose MongoDB and RabbitMQ to the internet
- Setup AGIC to expose ArgoCD dashboard to the internet 

Todo:
- Use Let's Encrypt to secure the web application
- Use LXC runtime to create multiple nodes


## Install MicroK8s

The solution will use Windows Subsystem for Linux (WSL2) to run Ubuntu and MicroK8s. The following steps will guide you through the installation of MicroK8s on Ubuntu running on WSL2. Keep in mind that most of the commands should be run in the Ubuntu terminal, which is running on WSL2.

### How to install MicroK8s on Ubuntu running on Windows WSL2

Install WSL2 on Windows
   - Follow the instructions from the [Microsoft documentation](https://docs.microsoft.com/en-us/windows/wsl/install) to install WSL2.

Other option could be to use Microsoft Store to install Ubuntu:

1. **Install Ubuntu from Microsoft Store**:
   - Open Microsoft Store and search for "Ubuntu"

   ![Open Microsoft Store](./assets/k8s_01.png)

   - Select the desired version of Ubuntu (e.g., Ubuntu 24.04 LTS)

   ![Select Distro](./assets/k8s_02.png)

   - Click on "Get" to install it.

2. **Install WSL2 by command line**:
   - Open PowerShell as Administrator and run the following command to set WSL2 as the default version:
     ```powershell
     wsl --set-default-version 2
     ```
   - Open PowerShell as Administrator and run:
     ```powershell
     wsl --install -d Ubuntu-24.04
     ```
   
After installation, you can open the Ubuntu terminal from the Start menu.

## Install microk8s on Ubuntu

1. First, install MicroK8s on your Ubuntu WSL2 VM
   ``` bash
   sudo snap install microk8s --classic
   ```

2. Add your user to the microk8s group to avoid using sudo with every command
   ``` bash
   sudo usermod -a -G microk8s $USER
   sudo chown -f -R $USER ~/.kube
   ```

3. Start MicroK8s and wait for it to be ready
   ``` bash
   # Start Microk8s
   microk8s start

   # Check status
   microk8s status --wait-ready
   ```
4. Enable essential addons for your cluster:
   ``` bash
   microk8s enable metallb       # For load balancing
   microk8s enable ingress       # For ingress controller
   microk8s enable dns           # For DNS resolution
   microk8s enable cert-manager  # For SSL/TLS certificate management
   ```

5. Enable community addons and other essential services:
   ``` bash
   microk8s enable community     # For community addons
   ```

6. Check community addons is enabled. By running microk8s status you can see the status of all addons: 
   ``` bash
   microk8s status               # To check the status of all addons
   ```

7. Enable ArgoCD for continuous deployment (ArgoCD is available in the community addons): 
   ``` bash
   microk8s enable argocd        # For continuous deployment
   ```

8. Run Kubernetes dashboard (Use a new terminal for this command):
   ``` bash
   # Access the dashboard
   microk8s dashboard-proxy
   ```

9. For WSL2 specific configuration, you'll need to set up port forwarding from Windows to WSL2. You can do this in PowerShell with either of these methods:
   ``` PowerShell
   ## Forward WSL2 IP connections to Windows host 
   
   ### Option 1
   wsl hostname -I
   netsh interface portproxy add v4tov4 listenport=80 listenaddress=0.0.0.0 connectport=80 connectaddress=<WSL2_IP>
   
   ### Option 2
   netsh interface portproxy set v4tov4 listenport=80 listenaddress=0.0.0.0 connectport=80 connectaddress=$(wsl hostname -I)
   ```

10. To verify your installation, you can run these commands:
    ``` bash
    # Check cluster status
    microk8s kubectl get nodes
 
    # Check all resources
    microk8s kubectl get all --all-namespaces
 
    # Create a test deployment by means of an Nginx image
    # This will create a simple Nginx deployment
    microk8s kubectl create deployment nginx --image=nginx
    ```

11. To stop MicroK8s when needed:
    ``` bash
    # Stop Microk8s
    microk8s stop
    ```

 **Important Notes**
> - Make sure your WSL2 VM has enough resources allocated (memory and CPU)
> - The default configuration creates a single-node cluster
> - You can use `microk8s kubectl` instead of `kubectl` for all Kubernetes commands
> - For development purposes, you might want to create an alias: `alias kubectl='microk8s kubectl'`


## Setup Helm
Helm is a package manager for Kubernetes that helps you manage Kubernetes applications. It allows you to define, install, and upgrade even the most complex Kubernetes applications. Follow these steps to use Helm with your MicroK8s cluster:


``` bash
# Install Helm
sudo snap install helm --classic
```

Upon installing Helm, a package manager for Kubernetes, you can use it to simplify application deployment and management. Here are some common Helm commands:

**Scenario N.1**

Create a new Helm chart from scratch, package it, and deploy it to your cluster

``` bash
# Create a new helm chart
helm create gnxchart

# Package a chart
cd ./deployments/helm
helm package gnxchart

# Install the chart on a specific namespace
helm install dev-gnx-1 ./gnxchart --namespace gnx-apps

# List all the helm charts
helm list

# List all the helm charts regardless of the namespace
helm list --all-namespaces

# Upgrade the helm chart by setting the replica count to 3
helm upgrade dev-gnx-1 ./gnxchart --namespace gnx-apps --set replicaCount=3

# Uninstall the helm chart
helm uninstall dev-gnx-1
```

## Setup nginx ingress controller
To set up the Nginx Ingress Controller in your MicroK8s cluster, follow these steps:

1. **Enable the Nginx Ingress Controller**:
   MicroK8s provides an easy way to enable the Nginx Ingress Controller. Run the following command:
   ```bash
   # Enable Nginx Ingress Controller
   microk8s enable ingress
   ```

2. **Verify the Ingress Controller is running**:
   After enabling the Ingress Controller, you can check its status by running:
   ```bash
   microk8s kubectl get pods -n kube-system
   ```
   Look for a pod with a name that starts with `nginx-ingress-controller`.

3. **Create an Ingress Resource**:
   You need to create an Ingress resource that defines how to route traffic to your services. Create a file named `ingress.yaml` with the following content:
   ```yaml
   apiVersion: networking.k8s.io/v1
   kind: Ingress
   metadata:
     name: my-ingress
     namespace: gnx-apps
   spec:
     rules:
     - host: myapp.example.com
       http:
         paths:
         >>>>>>>> TOBE CONTINUED <<<<<<<<
   ```

In case you want to use the Nginx Ingress Controller with Let's Encrypt for SSL/TLS certificates, you can follow these additional steps:
```yaml
TBW
```

To install the Nginx with helmchart, you can use the following command:
```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx -namespace ingress-nginx --create-namespace
```

In case you want to run the above commands, all togheter, follow the command below:
```bash
# Everything in one command
helm upgrade --install ingress-nginx ingress-nginx --repo https://kubernetes.github.io/ingress-nginx --namespace ingress-nginx --create-namespace
```


## Enable IP Forwarding

``` bash
# Install iptables if not already installed
sudo apt install iptables

# Check if iptables is installed
iptables --version

# Check current iptables rules
iptables -L

# Check NAT table rules
iptables -t nat -L

sysctl net.ipv4.ip_forward=1

# Add your forwarding rule (use n.n.n.n:port):
iptables -t nat -A PREROUTING -p tcp -d <your-src-port> --dport 5101 -j DNAT --to-destination <your-destination-ip>:80

# Ask IPtables to Masquerade:
iptables -t nat -A POSTROUTING ! -s 127.0.0.1 -j MASQUERADE


netsh interface portproxy show all
```

----
# Setup Kubernetes Dashboard


To set up the Kubernetes Dashboard in your MicroK8s cluster, follow these steps:


### Setup MicroK8s Dashboard to Start Automatically

To set up MicroK8s to automatically start the dashboard when the cluster starts, we need to create a `systemd service`. Here's how to do it:

1. Create a `systemd service` file for the dashboard. Create a new file at `/etc/systemd/system/microk8s-dashboard.service` with the following content:

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
- Be accessible at [https://localhost:10443](https://localhost:10443) from your Windows host
- Persist across WSL2 restarts

To access the dashboard:
1. Open your browser and navigate to [https://localhost:10443](https://localhost:10443)
2. You'll need to get the token for authentication:
   ```bash
   microk8s kubectl create token default -n kube-system
   ```

### How to setup pull images from private registry
To set up your MicroK8s cluster to pull images from a private registry, you need to create a Kubernetes secret that contains your registry credentials. Here's how to do it:
```bash
# Create a secret for your private registry
microk8s kubectl create secret docker-registry my-registry-secret \
  --docker-server=<your-registry-server> \
  --docker-username=<your-username> \
  --docker-password=<your-password> \
  --docker-email=<your-email> \
  --namespace <your-app-namespace>
```
Replace `<your-registry-server>`, `<your-username>`, `<your-password>`, and `<your-email>` with your actual registry details.
# Use the secret in your deployment
When you create or update your deployment, specify the imagePullSecrets field to use the secret you just created. Here's an example of how to do this in a deployment YAML file:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  namespace: gnx-apps
spec:
   replicas: 1
   selector:
      matchLabels:
         app: my-app
   template:
      metadata:
         labels:
         app: my-app
      spec:
         imagePullSecrets:
         - name: my-registry-secret
         containers:
         - name: my-container
         image: <your-registry-server>/<your-image>:<tag>
         ports:
         - containerPort: 80
   ```

After applying this deployment, your MicroK8s cluster will use the specified secret to authenticate with your private registry when pulling images.


Official documentation for MicroK8s can be found at [MicroK8s Documentation](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/)

# How to setup Let's Encrypt with Nginx Ingress Controller
To set up Let's Encrypt with the Nginx Ingress Controller in your MicroK8s cluster, follow these steps:
1. **Install the Nginx Ingress Controller**:
   If you haven't already installed the Nginx Ingress Controller, you can do so with the following command:
   ```bash
   microk8s enable ingress
   ```
2. **Install Cert-Manager**:
   Cert-Manager is a Kubernetes add-on that automates the management and issuance of TLS certificates from various issuing sources, including Let's Encrypt. You can enable it with:
   ```bash
   microk8s enable cert-manager
   ```
3. **Create a ClusterIssuer**:
   A ClusterIssuer is a resource that defines how certificates should be issued. Create a YAML file named `cluster-issuer.yml` with the following content:
   ```yaml
   apiVersion: cert-manager.io/v1
   kind: ClusterIssuer
   metadata:
     name: letsencrypt-prod
   spec:
     acme:
       server: https://acme-v02.api.letsencrypt.org/directory
       email:  <


----

# Application Deployment

``` bash
# Initialize infrastructure services
bash ./01-cluster-initialize/setup-infrastructure.sh
```


### Useful Commands

Following is a list of useful commands:
``` bash
# Create namespace
microk8s kubectl create namespace gnx-apps

# Create deployment (use it as hello world application)
microk8s kubectl create deployment nginx --image=nginx
microk8s kubectl create deployment microbot --image=dontrebootme/microbot:v1

# Create a deployment on a namespace
microk8s kubectl create deployment --namespace=gnx-apps microbot --image=dontrebootme/microbot:v1

# delete deployment
microk8s kubectl delete deployment microbot

# Create service
microk8s kubectl expose deployment nginx --port 5101 --target-port 80 --selector app=nginx --type LoadBalancer --name nginx2
microk8s kubectl expose deployment --namespace=gnx-apps nginx --port 5101 --target-port 80 --selector app=nginx --type LoadBalancer --name nginx2
microk8s kubectl expose deployment --namespace=gnx-apps apigateway --port 5180 --target-port 80 --type LoadBalancer --name apigateway2
microk8s kubectl expose deployment --namespace=gnx-apps apigateway --port 80 --type ClusterIP --name apigateway2

# Scale deployments
microk8s kubectl scale deployment nginx --replicas=1

watch microk8s kubectl get all

microk8s kubectl port-forward -n default service/microbot 80:80 --address 0.0.0.0
```

To run the application, you can use the following commands:
``` bash
# Use yaml files
microk8s kubectl apply -f ./deployment/namespace.yml
microk8s kubectl apply -f ./deployment/secrets.yml
microk8s kubectl apply -f ./deployment/nginx-ingress.yml
microk8s kubectl apply -f ./deployment/cert-manager.yml
microk8s kubectl apply -f ./deployment/apigateway.yml
microk8s kubectl apply -f ./deployment/identities.yml
microk8s kubectl apply -f ./deployment/products.yml
microk8s kubectl apply -f ./deployment/orders.yml
microk8s kubectl apply -f ./deployment/notifications.yml
```

or alternatively, you can use the following command to deploy the application:


This section describe the repository folders along with a brief description of their contents:

## 01-setup-infrasctructure
This folder contains scripts and configurations to set up the infrastructure for the Genocs Library K8s challenge. It includes:
- setup-infrastructure.sh: A script to initialize the infrastructure services.


## 02-deploy-application
This folder contains the deployment configurations for the Genocs Library application.


``` bash
# Initialize infrastructure services
bash ./01-cluster-initialize/setup-infrastructure.sh
```


# Miscellaneous

References and resources used in this project:
- [Genocs Library](https://genocs.com/library/)

- [Windows Subsystem for Linux (WSL2)](https://docs.microsoft.com/en-us/windows/wsl/install)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
- [MicroK8s Documentation](https://microk8s.io/docs)
- [Kubernetes Dashboard Documentation](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)
- [Helm Documentation](https://helm.sh/docs/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/en/stable/)
- [Nginx Ingress Controller Documentation](https://kubernetes.github.io/ingress-nginx/)
- [Cert-Manager Documentation](https://cert-manager.io/docs/)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)
- [MongoDB Documentation](https://docs.mongodb.com/)
- [RabbitMQ Documentation](https://www.rabbitmq.com/documentation.html)

- [linux container virtualization](https://linuxcontainers.org/)