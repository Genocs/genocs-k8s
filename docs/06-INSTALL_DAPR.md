# Install Dapr on Kubernetes

Dapr is a portable, event-driven runtime that makes it easy to build resilient, stateless, and stateful applications that run on the cloud and edge.

## Prerequisites

Before installing Dapr, ensure you have:

- A running Minikube cluster
- `kubectl` configured to communicate with your cluster
- `helm` installed (version 3.0 or later)
- `dapr` CLI installed

## Step 1: Install Dapr CLI

First, install the Dapr CLI on your system:

### For Ubuntu/Debian:

```bash
wget -q -O - https://raw.githubusercontent.com/dapr/cli/master/install/install.sh | /bin/bash
```

### For macOS:

```bash
brew install dapr/tap/dapr-cli
```

### For Windows (PowerShell):

```powershell
powershell -Command "iwr -useb https://raw.githubusercontent.com/dapr/cli/master/install/install.ps1 | iex"
```

### Verify Installation:

```bash
dapr --version
```

## Step 2: Initialize Dapr in Your Kubernetes Cluster

Initialize Dapr in your Minikube cluster:

```bash
dapr init --kubernetes --wait
```

This command will:

- Install Dapr control plane components
- Create the `dapr-system` namespace
- Deploy Dapr services (operator, placement, sentry, dashboard)
- Wait for all components to be ready

## Step 3: Verify Dapr Installation

Check that all Dapr components are running:

```bash
# Check Dapr system namespace
kubectl get pods -n dapr-system

# Check Dapr services
kubectl get services -n dapr-system

# Check Dapr CRDs
kubectl get crd | grep dapr
```

Expected output should show:

- `dapr-operator` pod running
- `dapr-placement` pod running
- `dapr-sentry` pod running
- `dapr-dashboard` pod running (optional)

## Step 4: Enable Dapr Sidecar Injection

Enable Dapr sidecar injection for your namespace:

```bash
# Create a namespace for your application (if not exists)
kubectl create namespace myapp

# Enable Dapr sidecar injection
kubectl label namespace myapp dapr.io/enabled=true
```

## Step 5: Install Dapr Components

Create and apply Dapr component configurations. Here are some common examples:

### State Store Component (Redis)

Create a file named `redis-state.yaml`:

```yaml
apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: statestore
  namespace: myapp
spec:
  type: state.redis
  version: v1
  metadata:
    - name: redisHost
      value: redis-master:6379
    - name: redisPassword
      value: ""
    - name: enableTLS
      value: "false"
```

Apply the component:

```bash
kubectl apply -f redis-state.yaml
```

### Pub/Sub Component (Redis)

Create a file named `redis-pubsub.yaml`:

```yaml
apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: pubsub
  namespace: myapp
spec:
  type: pubsub.redis
  version: v1
  metadata:
    - name: redisHost
      value: redis-master:6379
    - name: redisPassword
      value: ""
    - name: enableTLS
      value: "false"
```

Apply the component:

```bash
kubectl apply -f redis-pubsub.yaml
```

## Step 6: Deploy a Sample Application

Deploy a simple application to test Dapr functionality:

### Create a sample application deployment:

Create a file named `sample-app.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
  namespace: myapp
  labels:
    app: sample-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: sample-app
  template:
    metadata:
      labels:
        app: sample-app
      annotations:
        dapr.io/enabled: "true"
        dapr.io/app-id: "sample-app"
        dapr.io/app-port: "3000"
    spec:
      containers:
        - name: sample-app
          image: node:16-alpine
          command: ["sh", "-c"]
          args:
            - |
              apk add --no-cache curl
              while true; do
                echo "Sample app running..."
                sleep 30
              done
          ports:
            - containerPort: 3000
---
apiVersion: v1
kind: Service
metadata:
  name: sample-app-service
  namespace: myapp
spec:
  selector:
    app: sample-app
  ports:
    - port: 80
      targetPort: 3000
  type: ClusterIP
```

Apply the deployment:

```bash
kubectl apply -f sample-app.yaml
```

## Step 7: Verify Dapr Sidecar Injection

Check that the Dapr sidecar was injected into your application:

```bash
# Check the pod details
kubectl describe pod -n myapp -l app=sample-app

# Check that both containers are running
kubectl get pods -n myapp -l app=sample-app
```

You should see two containers in the pod:

- Your application container
- The Dapr sidecar container (`daprd`)

## Step 8: Access Dapr Dashboard (Optional)

To access the Dapr dashboard:

```bash
# Port forward the Dapr dashboard
kubectl port-forward -n dapr-system svc/dapr-dashboard 8080:8080
```

Then open your browser and navigate to `http://localhost:8080`

## Step 9: Test Dapr Functionality

Test the state store functionality:

```bash
# Get the pod name
POD_NAME=$(kubectl get pods -n myapp -l app=sample-app -o jsonpath='{.items[0].metadata.name}')

# Test state store operations
kubectl exec -n myapp $POD_NAME -c sample-app -- curl -X POST "http://localhost:3500/v1.0/state/statestore" \
  -H "Content-Type: application/json" \
  -d '[
    {
      "key": "test-key",
      "value": "test-value"
    }
  ]'

# Retrieve the value
kubectl exec -n myapp $POD_NAME -c sample-app -- curl "http://localhost:3500/v1.0/state/statestore/test-key"
```

## Troubleshooting

### Common Issues:

1. **Dapr components not ready:**

   ```bash
   kubectl get pods -n dapr-system
   kubectl logs -n dapr-system deployment/dapr-operator
   ```

2. **Sidecar injection not working:**

   ```bash
   # Check namespace labels
   kubectl get namespace myapp --show-labels

   # Check pod annotations
   kubectl get pod -n myapp -o yaml | grep -A 10 annotations
   ```

3. **Component configuration issues:**

   ```bash
   # Check component status
   kubectl get components -n myapp

   # Check component logs
   kubectl logs -n myapp -l app=sample-app -c daprd
   ```

### Uninstall Dapr:

To remove Dapr from your cluster:

```bash
# Remove Dapr from the cluster
dapr uninstall --kubernetes

# Remove Dapr CLI
# For Ubuntu/Debian:
sudo rm /usr/local/bin/dapr

# For macOS:
brew uninstall dapr-cli
```

## Next Steps

After successfully installing Dapr, you can:

1. Deploy your applications with Dapr annotations
2. Configure additional components (databases, message brokers, etc.)
3. Implement Dapr building blocks in your applications
4. Set up monitoring and observability

## References

- [Dapr Official Documentation](https://docs.dapr.io/)
- [Dapr Kubernetes Installation Guide](https://docs.dapr.io/getting-started/install-dapr-kubernetes/)
- [Dapr Building Blocks](https://docs.dapr.io/concepts/building-blocks-concept/)
- [Dapr Components](https://docs.dapr.io/concepts/components-concept/)
