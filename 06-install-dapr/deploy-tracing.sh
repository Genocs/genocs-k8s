#!/bin/bash

# Dapr Tracing Setup with Zipkin Deployment Script
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Dapr Tracing Setup with Zipkin${NC}"
echo -e "${BLUE}================================${NC}"

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

# Check if Dapr is installed
if ! kubectl get namespace dapr-system &> /dev/null; then
    echo -e "${RED}❌ Dapr is not installed. Please install Dapr first.${NC}"
    echo -e "${YELLOW}   Run: dapr init -k${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"

# Create namespace if it doesn't exist
echo -e "${YELLOW}📁 Checking namespace...${NC}"
if ! kubectl get namespace myapp &> /dev/null; then
    echo -e "${YELLOW}📁 Creating namespace: myapp${NC}"
    kubectl create namespace myapp
else
    echo -e "${GREEN}✅ Namespace 'myapp' already exists${NC}"
fi

# Deploy Zipkin
echo -e "${YELLOW}📦 Deploying Zipkin...${NC}"
kubectl apply -f zipkin-deployment.yaml

# Wait for Zipkin to be ready
echo -e "${YELLOW}⏳ Waiting for Zipkin to be ready...${NC}"
kubectl wait --for=condition=available --timeout=300s deployment/zipkin -n default

# Deploy Dapr configuration
echo -e "${YELLOW}⚙️  Deploying Dapr tracing configuration...${NC}"
kubectl apply -f tracing.yaml

# Deploy Zipkin component
echo -e "${YELLOW}🔧 Deploying Zipkin component...${NC}"
kubectl apply -f zipkin.yaml

# Deploy sample application
echo -e "${YELLOW}🚀 Deploying sample application...${NC}"
kubectl apply -f sample-app.yaml

# Wait for sample app to be ready
echo -e "${YELLOW}⏳ Waiting for sample application to be ready...${NC}"
kubectl wait --for=condition=available --timeout=300s deployment/sample-app -n myapp

echo -e "${GREEN}✅ Deployment completed successfully!${NC}"

# Show deployment status
echo -e "${YELLOW}📊 Deployment Status:${NC}"
echo -e "${BLUE}Zipkin:${NC}"
kubectl get pods -l app=zipkin -n default

echo -e "${BLUE}Sample App:${NC}"
kubectl get pods -l app=sample-app -n myapp

echo -e "${BLUE}Services:${NC}"
kubectl get svc -l app=zipkin -n default
kubectl get svc -l app=sample-app -n myapp

echo -e "${BLUE}Dapr Components:${NC}"
kubectl get components -n default

echo -e "${BLUE}Dapr Configurations:${NC}"
kubectl get configurations -n default

echo -e "${GREEN}🎉 Dapr Tracing Setup Complete!${NC}"
echo -e "${YELLOW}Access Points:${NC}"
echo -e "  - Zipkin UI: http://zipkin.local (add to /etc/hosts: <cluster-ip> zipkin.local)"
echo -e "  - Sample App: kubectl port-forward svc/sample-app-service 8080:80 -n myapp"
echo -e "  - Sample App URL: http://localhost:8080"
echo -e ""
echo -e "${YELLOW}Useful Commands:${NC}"
echo -e "  - View Zipkin logs: kubectl logs -f deployment/zipkin -n default"
echo -e "  - View sample app logs: kubectl logs -f deployment/sample-app -n myapp"
echo -e "  - Check Dapr sidecar: kubectl logs -f deployment/sample-app -c daprd -n myapp"
echo -e ""
echo -e "${YELLOW}Testing Tracing:${NC}"
echo -e "  1. Access the sample app: curl http://localhost:8080"
echo -e "  2. Check Zipkin UI for traces: http://zipkin.local"
echo -e "  3. Look for traces from 'sample-app' service"
