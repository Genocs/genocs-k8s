#!/bin/bash

# Variables
MONGODB_VALUES_FILE="./mongodb-values.yaml"   # Path to your MongoDB custom values file
RABBITMQ_VALUES_FILE="./rabbitmq-values.yaml" # Path to your RabbitMQ custom values file
DAPR_VALUES_FILE="./dapr-values.yaml"         # Path to your Dapr custom values file
ARGOCD_VALUES_FILE="./argocd-values.yaml"     # Path to your ArgoCD custom values file
GRAFANA_VALUES_FILE="./grafana-values.yaml"   # Path to your Grafana custom values file

# Check if the MongoDB values file exists
if [[ ! -f "$MONGODB_VALUES_FILE" ]]; then
    echo "Custom values file $MONGODB_VALUES_FILE not found!"
    exit 1
fi

# Check if the RABBITMQ values file exists
if [[ ! -f "$RABBITMQ_VALUES_FILE" ]]; then
    echo "Custom values file $RABBITMQ_VALUES_FILE not found!"
    exit 1
fi

# Check if the DAPR values file exists
if [[ ! -f "$DAPR_VALUES_FILE" ]]; then
    echo "Custom values file $DAPR_VALUES_FILE not found!"
    exit 1
fi

# Check if the ArgoCD values file exists
if [[ ! -f "$ARGOCD_VALUES_FILE" ]]; then
    echo "Custom values file $ARGOCD_VALUES_FILE not found!"
    exit 1
fi

# Check if the GRAFANA values file exists
if [[ ! -f "$GRAFANA_VALUES_FILE" ]]; then
    echo "Custom values file $GRAFANA_VALUES_FILE not found!"
    exit 1
fi

# Update Helm repo (optional)
echo "Updating Helm repositories..."
helm repo update


# Install/Update Helm Rabbitmq repo 
echo "Updating/Installing RabbitMQ service..."
helm upgrade --install rabbitmq -f rabbitmq-values.yaml oci://registry-1.docker.io/bitnamicharts/rabbitmq -n rabbitmq --create-namespace
echo "Updating/Installing RabbitMQ service completed..."
echo "----------------------------------------------------"

# Install/Update Helm Mongodb repo 
echo "Udating/Installing Mongodb service..."
helm upgrade --install mongodb -f mongodb-values.yaml oci://registry-1.docker.io/bitnamicharts/mongodb -n mongodb --create-namespace
echo "Updating/Installing Mongodb service completed..."
echo "----------------------------------------------------"

# Install/Update Dapr service
echo "Updating/Installing Dapr service..."

# Add the official Dapr Helm chart.
helm repo add dapr https://dapr.github.io/helm-charts/
helm repo update

helm install dapr dapr/dapr --namespace dapr --create-namespace --values dapr-values.yaml --wait
echo "Updating/Installing Dapr service completed..."
echo "----------------------------------------------------"

Install/Update ArgoCD service
echo "Updating/Installing ArgoCD service..."
helm upgrade --install argocd -f argocd-values.yaml oci://registry-1.docker.io/bitnamicharts/argo-cd -n argocd --create-namespace
echo "Updating/Installing ArgoCD service completed..."
echo "----------------------------------------------------"


# Install/Update Grafana service
echo "Updating/Installing Grafana service..."
helm upgrade --install grafana -f grafana-values.yaml oci://registry-1.docker.io/bitnamicharts/grafana -n grafana --create-namespace
echo "Updating/Installing Grafana service completed..."
echo "----------------------------------------------------"

# Install/Update Backend services repo 
echo "build dependency..."
helm dependency build .
echo "----------------------------------------------------"

echo "build dependency list..."
helm dependency list
echo "----------------------------------------------------"

# Delay for 10 seconds to allow Helm to process the install/upgrade
echo "Waiting for 30 seconds for the installation to stabilize..."
sleep 30

# Verify the installation
echo "Verifying the installation..."
kubectl get pods --namespace mongodb
kubectl get pods --namespace rabbitmq
kubectl get pods --namespace dapr
kubectl get pods --namespace argocd
kubectl get pods --namespace grafana
echo "Installation verification completed."
echo "----------------------------------------------------"

echo "To access the ArgoCD UI, run the following command:"
echo "kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "To access the Grafana UI, run the following command:"
echo "kubectl port-forward svc/grafana -n grafana 3000:80"
echo "To access the RabbitMQ UI, run the following command:"
echo "kubectl port-forward svc/rabbitmq -n rabbitmq 15672:15672"
echo "To access the MongoDB UI, run the following command:"
echo "kubectl port-forward svc/mongodb -n mongodb 27017:27017"
echo "To access the Dapr Operator, run the following command:"
echo "kubectl port-forward dapr-operator-<your_id> 40000:40000 -n dapr

