## Setup Helm

Helm is a package manager for Kubernetes that helps you manage Kubernetes applications. It allows you to define, install, and upgrade even the most complex Kubernetes applications. Follow these steps to use Helm with your MicroK8s cluster:

```bash
# Install Helm
sudo snap install helm --classic
```

Upon installing Helm, a package manager for Kubernetes, you can use it to simplify application deployment and management. Here are some common Helm commands:

**Scenario N.1**

Create a new Helm chart from scratch, package it, and deploy it to your cluster

```bash
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
       email: <
   ```

---

# Application Deployment

```bash
# Initialize infrastructure services
bash ./01-cluster-initialize/setup-infrastructure.sh
```

### Useful Commands

Following is a list of useful commands:

```bash
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

```bash
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
