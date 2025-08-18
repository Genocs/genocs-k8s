# RabbitMQ on Kubernetes

RabitMQ is a widely used open-source message broker that supports multiple messaging protocols. It is designed for high availability and scalability, making it suitable for various applications, including microservices architectures.

To setup a RabbitMQ HA cluster, it's recomended to have at least 3 nodes in your K8s cluster. This ensures that RabbitMQ can maintain quorum and provide high availability.

In this guide, we will walk you through the process of setting up RabbitMQ in a High Availability (HA) configuration on your Kubernetes (K8s) cluster using the RabbitMQ Cluster Operator.

## Pre-requisites

Before you begin, ensure that you have the following components installed and configured in your cluster:

you need to have the following prerequisites in place:

1. **MicroK8s Cluster**: Ensure you have a MicroK8s cluster running. You can set it up by following the [MicroK8s installation guide](https://microk8s.io/docs).
2. **Minikube**: If you are using Minikube, ensure it is installed and running. You can follow the [Minikube installation guide](https://minikube.sigs.k8s.io/docs/start/).
3. **kubectl**: Make sure you have `kubectl` installed and configured to interact with your MicroK8s cluster.

## Install RabbitMQ Cluster Operator

To install RabbitMQ Cluster Operator, you can read [official documentation](https://www.rabbitmq.com/kubernetes/operator/quickstart-operator)

Follow these steps to install the RabbitMQ Cluster Operator:

```bash
# Install RabbitMQ Cluster Operator
kubectl apply -f "https://github.com/rabbitmq/cluster-operator/releases/latest/download/cluster-operator.yml"
```

```plaintext
# Output:
# namespace/rabbitmq-system created
# customresourcedefinition.apiextensions.k8s.io/rabbitmqclusters.rabbitmq.com created
# serviceaccount/rabbitmq-cluster-operator created
# role.rbac.authorization.k8s.io/rabbitmq-cluster-leader-election-role created
# clusterrole.rbac.authorization.k8s.io/rabbitmq-cluster-operator-role created
# rolebinding.rbac.authorization.k8s.io/rabbitmq-cluster-leader-election-rolebinding created
# clusterrolebinding.rbac.authorization.k8s.io/rabbitmq-cluster-operator-rolebinding created
# deployment.apps/rabbitmq-cluster-operator created
```

## Install the cert-manager

The `cert-manager` is responsible for managing TLS certificates in your Kubernetes cluster, which is essential for securing RabbitMQ communication.
You can read more about cert-manager in the [official documentation](https://cert-manager.io/docs/installation/kubectl/).

To install the `cert-manager`, you can use the following command.

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.17.2/cert-manager.yaml
```

## Install RabbitMQ Topology Operator

The RabbitMQ Topology Operator is used to manage RabbitMQ resources in a Kubernetes cluster. It provides a way to define and manage RabbitMQ exchanges, queues, bindings, and other resources declaratively.

You can read more about the RabbitMQ Topology Operator in the [official documentation](https://www.rabbitmq.com/kubernetes/operator/install-topology-operator/).

```bash
kubectl apply -f https://github.com/rabbitmq/messaging-topology-operator/releases/latest/download/messaging-topology-operator-with-certmanager.yaml
```

## Create RabbitMQ Cluster

To create a RabbitMQ cluster, you need to define a `RabbitmqCluster` resource. This resource specifies the desired state of your RabbitMQ cluster, including the number of replicas and other configurations.

You can create a RabbitMQ cluster by applying a YAML file that defines the `RabbitmqCluster` resource. Below is an example of how to create a RabbitMQ cluster with 3 replicas.

### Hello World Example

This is an hello-world example of a RabbitMQ cluster configuration. It creates a RabbitMQ cluster with 3 replicas, which is suitable for high availability.
You can customize the configuration according to your requirements.

```bash
# Create a RabbitMQ cluster with basic configuration
kubectl apply -f https://raw.githubusercontent.com/rabbitmq/cluster-operator/main/docs/examples/hello-world/rabbitmq.yaml
```

Following the yaml file is an example of a RabbitMQ cluster configuration. It creates a RabbitMQ cluster with 3 replicas, which is suitable for high availability. You can customize the configuration according to your requirements.

```yaml
apiVersion: rabbitmq.com/v1beta1
kind: RabbitmqCluster
metadata:
  name: gnx-rabbitmq
```

### Real world example

In this section willl be created a RabbitMQ cluster with 3 replicas, which is suitable for high availability with a storage class.

The storage class is used to define the storage requirements for the RabbitMQ cluster. It ensures that the RabbitMQ pods have persistent storage for their data.

```bash
# Create a RabbitMQ cluster with storage class
kubectl apply -f ./06-install-rabbitmq/storage-class.yaml

# Create the Persistent Volume (PV) for RabbitMQ nodes
kubectl apply -f ./06-install-rabbitmq/pv.yaml
kubectl apply -f ./06-install-rabbitmq/pv-node1.yaml
kubectl apply -f ./06-install-rabbitmq/pv-node2.yaml
kubectl apply -f ./06-install-rabbitmq/pv-node3.yaml
```

## RabbitMQ Cluster Configuration

The following YAML file defines the RabbitMQ cluster configuration. It specifies the number of replicas, storage class, and other configurations.

```yaml
apiVersion: rabbitmq.com/v1beta1
kind: RabbitmqCluster
metadata:
  name: gnx-rabbitmq
spec:
  replicas: 3
  storage:
    storageClassName: gnx-rabbitmq-storage
    persistentVolumeClaimTemplate:
      spec:
        accessModes:
          - ReadWriteOnce
        resources:
          requests:
            storage: 1Gi
  service:
    type: ClusterIP
  rabbitmq:
    additionalPlugins:
      - rabbitmq_peer_discovery_k8s
      - rabbitmq_management_agent
      - rabbitmq_prometheus
```

---

## Installing RabbitMQ Cluster with Helm

You can also install RabbitMQ using Helm, which is a package manager for Kubernetes. This method allows you to easily manage and upgrade your RabbitMQ installation.

```bash
# Add the RabbitMQ Helm repository
helm repo add bitnami https://charts.bitnami.com/bitnami
# Update the Helm repository
helm repo update
# Install RabbitMQ using Helm
helm install gnx-rabbitmq bitnami/rabbitmq --set auth.username=guest --set auth.password=guest --set auth.erlangCookie=cookie123 --set service.type=ClusterIP --set persistence.storageClass=gnx-rabbitmq-storage --set persistence.size=1Gi
```

helm install gnx-rabbitmq oci://registry-1.docker.io/bitnamicharts/rabbitmq -f ./06-install-rabbitmq/helm-settings.yaml

````

```bash
helm list
helm search repo rabbitmq
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Show the values of the RabbitMQ Helm chart
helm show values bitnami/rabbitmq

helm upgrade --install gnx-rabbitmq -f ./06-install-rabbitmq/helm-settings.yaml bitnami/rabbitmq
````
