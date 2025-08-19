# Miscellaneous


- [Kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/) is a tool provided by Kubernetes to help you bootstrap a Kubernetes cluster. It simplifies the process of setting up a cluster by automating tasks such as generating certificates, creating configuration files, and starting the control plane components.


## MicroK8s

- [MicroK8s](https://microk8s.io/) is a lightweight, single-package Kubernetes distribution designed for developers and DevOps teams. It provides a simple way to run Kubernetes on your local machine or in the cloud, with minimal setup and resource requirements.

## K3s

- [K3s](https://k3s.io/) is a lightweight, certified Kubernetes distribution designed for resource-constrained environments and edge computing. It is easy to install and maintain, making it ideal for IoT devices, ARM processors, and low-resource systems.

- [Dapr](https://www.dapr.io/) is a portable, event-driven runtime that makes it easy for developers to build resilient, stateless, and stateful applications that run on the cloud and edge. It provides APIs for common application patterns such as service invocation, state management, pub/sub messaging, and more.

- [KEDA](https://keda.sh/) (Kubernetes-based Event Driven Autoscaling) is a Kubernetes-based component that allows you to scale applications based on the number of events needing to be processed. It works with any containerized workload and can be used with various event sources like Kafka, RabbitMQ, Azure Queue Storage, and more.

## Setup kind cluster

To set up a kind cluster, you can use the following command with a configuration file:

```bash
kind create cluster --config 05-kind-multinode/kind-cluster-config.yaml
```

This command will create a Kubernetes cluster using the configuration specified in the `kind-cluster-config.yaml` file. The configuration file allows you to customize the cluster settings, such as the number of nodes, their roles, and other parameters.




# How to setup pull images from private registry

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