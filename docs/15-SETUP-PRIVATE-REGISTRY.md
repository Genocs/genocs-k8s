# Setting Up Private Registry Access in Kubernetes

This guide provides comprehensive instructions for configuring your Kubernetes cluster to pull images from private container registries, including Docker Hub, Azure Container Registry (ACR), Google Container Registry (GCR), and other private registries.

## Overview

When deploying applications that use images from private registries, Kubernetes needs authentication credentials to pull these images. This setup involves:

- Creating Kubernetes secrets with registry credentials
- Configuring deployments to use these secrets
- Managing secrets across different namespaces
- Setting up image pull policies

## Prerequisites

Before you begin, ensure you have:

- **Kubernetes cluster**: Running cluster (MicroK8s, Kind, Minikube, etc.)
- **kubectl**: Kubernetes command-line tool configured
- **Registry credentials**: Username, password, and registry URL
- **Namespace**: Target namespace for your application

## Step 1: Create Registry Secret

### Docker Hub Private Registry

For Docker Hub private repositories:

```bash
# Create a secret for Docker Hub
kubectl create secret docker-registry dockerhub-secret \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=<your-dockerhub-username> \
  --docker-password=<your-dockerhub-password> \
  --docker-email=<your-email> \
  --namespace=<your-namespace>

# Verify the secret was created
kubectl get secret dockerhub-secret --namespace=<your-namespace> -o yaml
```

### Azure Container Registry (ACR)

For Azure Container Registry:

```bash
# Get ACR credentials
az acr credential show --name <your-acr-name>

# Create secret using ACR credentials
kubectl create secret docker-registry acr-secret \
  --docker-server=<your-acr-name>.azurecr.io \
  --docker-username=<acr-username> \
  --docker-password=<acr-password> \
  --namespace=<your-namespace>
```

### Google Container Registry (GCR)

For Google Container Registry:

```bash
# Create secret for GCR
kubectl create secret docker-registry gcr-secret \
  --docker-server=gcr.io \
  --docker-username=_json_key \
  --docker-password="$(cat /path/to/service-account-key.json)" \
  --docker-email=<your-email> \
  --namespace=<your-namespace>
```

### Generic Private Registry

For any private registry:

```bash
# Create secret for generic private registry
kubectl create secret docker-registry private-registry-secret \
  --docker-server=<your-registry-server> \
  --docker-username=<your-username> \
  --docker-password=<your-password> \
  --docker-email=<your-email> \
  --namespace=<your-namespace>

# Create a secret for Docker Hub
kubectl create secret docker-registry dockerhub-secret \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=<your-dockerhub-username> \
  --docker-password=<your-dockerhub-password> \
  --docker-email=<your-email> \
  --namespace=<your-namespace>

# Verify the secret was created
kubectl get secret dockerhub-secret --namespace=<your-namespace> -o yaml
```

Replace `<your-registry-server>`, `<your-username>`, `<your-password>`, and `<your-email>` with your actual registry details.


## Step 2: Configure Deployment to Use Secret

### Method 1: Using imagePullSecrets in Pod Spec

Add the `imagePullSecrets` field to your deployment:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-application
  namespace: my-namespace
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-application
  template:
    metadata:
      labels:
        app: my-application
    spec:
      imagePullSecrets:
        - name: dockerhub-secret
      containers:
        - name: my-container
          image: your-registry/your-image:latest
          ports:
            - containerPort: 8080
          resources:
            requests:
              memory: "64Mi"
              cpu: "250m"
            limits:
              memory: "128Mi"
              cpu: "500m"
```

### Method 2: Using ServiceAccount (Recommended)

Create a ServiceAccount with the image pull secret:

```yaml
# Create ServiceAccount with image pull secret
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-app-serviceaccount
  namespace: my-namespace
imagePullSecrets:
  - name: dockerhub-secret
---
# Use ServiceAccount in deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-application
  namespace: my-namespace
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-application
  template:
    metadata:
      labels:
        app: my-application
    spec:
      serviceAccountName: my-app-serviceaccount
      containers:
        - name: my-container
          image: your-registry/your-image:latest
          ports:
            - containerPort: 8080
```

## Step 3: Apply the Configuration

```bash
# Apply the deployment
kubectl apply -f deployment.yaml

# Verify the deployment
kubectl get deployments --namespace=<your-namespace>
kubectl get pods --namespace=<your-namespace>

# Check pod events for any image pull issues
kubectl describe pod <pod-name> --namespace=<your-namespace>
```

## Step 4: Verify Image Pull

### Check Pod Status

```bash
# Check if pods are running
kubectl get pods --namespace=<your-namespace>

# Check pod events
kubectl describe pod <pod-name> --namespace=<your-namespace>

# Check pod logs
kubectl logs <pod-name> --namespace=<your-namespace>
```

### Common Status Messages

- **ImagePullBackOff**: Authentication failed or image doesn't exist
- **ErrImagePull**: Network issues or invalid image reference
- **Pending**: Pod is waiting for image pull to complete

## Step 5: Cross-Namespace Secret Management

### Copy Secret to Multiple Namespaces

If you need the same registry access across multiple namespaces:

```bash
# Create secret in multiple namespaces
for namespace in namespace1 namespace2 namespace3; do
  kubectl create secret docker-registry dockerhub-secret \
    --docker-server=https://index.docker.io/v1/ \
    --docker-username=<your-username> \
    --docker-password=<your-password> \
    --docker-email=<your-email> \
    --namespace=$namespace
done
```

### Using kubectl copy

```bash
# Copy secret from one namespace to another
kubectl get secret dockerhub-secret --namespace=source-namespace -o yaml | \
  sed 's/namespace: source-namespace/namespace: target-namespace/' | \
  kubectl apply -f -
```

## Advanced Configuration

### Image Pull Policy

Configure how Kubernetes handles image pulling:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-application
spec:
  template:
    spec:
      containers:
        - name: my-container
          image: your-registry/your-image:latest
          imagePullPolicy: Always # Options: Always, IfNotPresent, Never
```

### Using ConfigMap for Registry Configuration

For complex registry setups:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: registry-config
  namespace: my-namespace
data:
  registry-url: "your-registry-server"
  registry-namespace: "your-namespace"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-application
spec:
  template:
    spec:
      containers:
        - name: my-container
          image: your-registry/your-image:latest
          env:
            - name: REGISTRY_URL
              valueFrom:
                configMapKeyRef:
                  name: registry-config
                  key: registry-url
```

## Troubleshooting

### Common Issues

#### Authentication Failures

```bash
# Check secret configuration
kubectl get secret <secret-name> --namespace=<namespace> -o yaml

# Verify secret data is base64 encoded
echo "<base64-encoded-password>" | base64 -d

# Test registry credentials manually
docker login <your-registry-server> -u <username> -p <password>
```

#### Image Pull Errors

```bash
# Check pod events
kubectl describe pod <pod-name> --namespace=<namespace>

# Check kubelet logs
kubectl logs -n kube-system kube-apiserver-<node-name>

# Verify image exists in registry
docker pull <your-registry>/<your-image>:<tag>
```

#### Network Issues

```bash
# Check cluster network connectivity
kubectl run test-pod --image=busybox --rm -it --restart=Never -- nslookup <your-registry-server>

# Test registry connectivity from cluster
kubectl run curl-test --image=curlimages/curl --rm -it --restart=Never -- curl -I https://<your-registry-server>
```

### Debugging Commands

```bash
# List all secrets in namespace
kubectl get secrets --namespace=<namespace>

# Describe secret details
kubectl describe secret <secret-name> --namespace=<namespace>

# Check ServiceAccount configuration
kubectl get serviceaccount --namespace=<namespace>
kubectl describe serviceaccount <serviceaccount-name> --namespace=<namespace>

# Verify image pull policy
kubectl get pod <pod-name> --namespace=<namespace> -o yaml | grep -A 5 imagePullPolicy
```

## Security Best Practices

### Secret Management

1. **Use Kubernetes secrets**: Store credentials securely in Kubernetes
2. **Rotate credentials regularly**: Update secrets periodically
3. **Limit access**: Use RBAC to control secret access
4. **Encrypt secrets**: Enable encryption at rest for secrets

### Registry Security

1. **Use HTTPS**: Always use secure connections to registries
2. **Implement scanning**: Scan images for vulnerabilities
3. **Use specific tags**: Avoid using `latest` tag in production
4. **Monitor access**: Log and monitor registry access

## Cleanup

To remove registry secrets:

```bash
# Delete secret from namespace
kubectl delete secret <secret-name> --namespace=<namespace>

# Delete ServiceAccount
kubectl delete serviceaccount <serviceaccount-name> --namespace=<namespace>

# Clean up deployments
kubectl delete deployment <deployment-name> --namespace=<namespace>
```

## Next Steps

After setting up private registry access, consider:

1. **Implementing image scanning**: Integrate vulnerability scanning
2. **Setting up CI/CD**: Automate image building and deployment
3. **Configuring monitoring**: Monitor image pull success rates
4. **Implementing backup**: Backup registry images and configurations

This setup provides secure and reliable access to private container registries in your Kubernetes cluster.



# How to setup pull images from private registry

To set up your MicroK8s cluster to pull images from a private registry, you need to create a Kubernetes secret that contains your registry credentials. Here's how to do it:


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