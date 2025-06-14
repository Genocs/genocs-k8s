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