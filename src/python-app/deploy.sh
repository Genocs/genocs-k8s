#!/bin/bash

# Python Web App Kubernetes Deployment Script
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="genocs/python-web-app"
IMAGE_TAG="1.0.0"
NAMESPACE="default"

echo -e "${GREEN}🚀 Starting Python Web App Deployment${NC}"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running. Please start Docker and try again.${NC}"
    exit 1
fi

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl is not installed. Please install kubectl and try again.${NC}"
    exit 1
fi

# Check if we can connect to Kubernetes cluster
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}❌ Cannot connect to Kubernetes cluster. Please check your kubeconfig.${NC}"
    exit 1
fi

echo -e "${YELLOW}📦 Building Docker image...${NC}"
docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -t ${IMAGE_NAME}:latest .

echo -e "${YELLOW}🔍 Checking if namespace exists...${NC}"
if ! kubectl get namespace ${NAMESPACE} &> /dev/null; then
    echo -e "${YELLOW}📁 Creating namespace: ${NAMESPACE}${NC}"
    kubectl create namespace ${NAMESPACE}
fi

echo -e "${YELLOW}📋 Applying Kubernetes manifests...${NC}"

# Apply ConfigMap first
kubectl apply -f k8s/configmap.yaml

# Apply Deployment
kubectl apply -f k8s/deployment.yaml

# Apply Service
kubectl apply -f k8s/service.yaml

# Apply HPA
kubectl apply -f k8s/hpa.yaml

# Apply Ingress (optional - comment out if you don't have ingress controller)
kubectl apply -f k8s/ingress.yaml

echo -e "${YELLOW}⏳ Waiting for deployment to be ready...${NC}"
kubectl wait --for=condition=available --timeout=300s deployment/python-web-app

echo -e "${GREEN}✅ Deployment completed successfully!${NC}"

# Show deployment status
echo -e "${YELLOW}📊 Deployment Status:${NC}"
kubectl get pods -l app=python-web-app

echo -e "${YELLOW}🌐 Service Status:${NC}"
kubectl get svc python-web-app-service

echo -e "${YELLOW}📈 HPA Status:${NC}"
kubectl get hpa python-web-app-hpa

echo -e "${GREEN}🎉 Python Web App is now deployed!${NC}"
echo -e "${YELLOW}To access the application:${NC}"
echo -e "  - Port forward: kubectl port-forward svc/python-web-app-service 8080:80"
echo -e "  - Then visit: http://localhost:8080"
echo -e "  - Health check: http://localhost:8080/health"
echo -e "  - Metrics: http://localhost:8080/metrics"
