# Genocs Library K8s walkthrough

## Introduction

The repository contains the solution for the Genocs Library K8s challenge. The solution is based on the following requirements:

- Use Genocs Library to build the services
- Host MicroK8s cluster onto Ubuntu Ubuntu 24.04.1 LTS VM  
- Create a Kubernetes cluster with 1 nodes
- Use Ngnix AGIC to expose the web application to the internet
- Deploy Genocs library application
- Use Helm chart to deploy the web application
- Use an internal API gateway to route the traffic to the web application
- Connect to an external MongoDB database
- Connect to an external RabbitMQ message broker 
- Use a Secret to store the database credentials
- Use a ConfigMap to store the web application configuration

Todo:
- Use Let's Encrypt to secure the web application
- Use LXC runtime to create multiple nodes
- Use a Persistent Volume to store the data

# Note to be considered

[linux container virtualization](https://linuxcontainers.org/)




## Install MicroK8s

```bash
# Start Microk8s
microk8s start

# Check status
microk8s status --wait-ready

# Stop Microk8s
microk8s stop

# Enable Addons (only once)
microk8s enable metallb
microk8s enable ingress
microk8s enable dns
microk8s enable cert-manager # In case you want to use certification manager along with Let's Encrypt 

# Start Dashboard
microk8s dashboard-proxy

# Create namespace
microk8s kubectl create namespace gnx-apps-ns

# Create deployment (use it as hello world application)
microk8s kubectl create deployment nginx --image=nginx
microk8s kubectl create deployment microbot --image=dontrebootme/microbot:v1

# Create a deployment on a namespace
microk8s kubectl create deployment --namespace=gnx-apps-ns microbot --image=dontrebootme/microbot:v1

# delete deployment
microk8s kubectl delete deployment microbot

# Create service
microk8s kubectl expose deployment nginx --port 5101 --target-port 80 --selector app=nginx --type LoadBalancer --name nginx2
microk8s kubectl expose deployment --namespace=gnx-apps-ns nginx --port 5101 --target-port 80 --selector app=nginx --type LoadBalancer --name nginx2
microk8s kubectl expose deployment --namespace=gnx-apps-ns apigateway --port 5180 --target-port 80 --type LoadBalancer --name apigateway2
microk8s kubectl expose deployment --namespace=gnx-apps-ns apigateway --port 80 --type ClusterIP --name apigateway2


# Scale deployments
microk8s kubectl scale deployment nginx --replicas=1

watch microk8s kubectl get all

microk8s kubectl port-forward -n default service/microbot 80:80 --address 0.0.0.0
```

To run the application, you can use the following commands:
```bash
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

```bash
bash deploy-services.sh
```

## How to use helm


```bash
# Install Helm
sudo snap install helm --classic

# Create a new helm chart (Warning: use it only to create a chart from scratch)
microk8s helm create gnxchart

# Package a chart

cd ./deployment/helm
microk8s helm package gnxchart

# Install
microk8s helm install dev-gnx-1 ./gnxchart --namespace gnx-apps-ns

# List all the helm charts
microk8s helm list

# Upgrade the helm chart
microk8s helm upgrade dev-gnx-1 ./gnxchart --namespace gnx-apps-ns --set replicaCount=3

# Uninstall the helm chart
microk8s helm uninstall dev-gnx-1
```


```bash
# Enable IP Forwarding:

sudo apt install iptables
iptables -t nat -L

sysctl net.ipv4.ip_forward=1
# Add your forwarding rule (use n.n.n.n:port):

iptables -t nat -A PREROUTING -p tcp -d 172.24.129.237 --dport 5101 -j DNAT --to-destination 10.1.203.0:80

# Ask IPtables to Masquerade:
iptables -t nat -A POSTROUTING ! -s 127.0.0.1 -j MASQUERADE


netsh interface portproxy show all

```

```PowerShell
## Forward WSL2 IP connections to Windows host 

### Option 1
wsl hostname -I
netsh interface portproxy add v4tov4 listenport=80 listenaddress=0.0.0.0 connectport=80 connectaddress=172.18.150.83

### Option 2
netsh interface portproxy set v4tov4 listenport=80 listenaddress=0.0.0.0 connectport=80 connectaddress=$(wsl hostname -I)
```