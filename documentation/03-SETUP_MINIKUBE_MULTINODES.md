# Setting Up Multi-Node Clusters

Minikube is primarily designed for local Kubernetes development and typically supports single-node clusters. However, you can simulate a multi-node cluster by creating multiple Minikube instances or using other tools like [Kind](https://kind.sigs.k8s.io/), [Minikube](https://minikube.sigs.k8s.io/docs/tutorials/multi_node/#hello-deployment.yaml) or K3d for true multi-node setups. 

There are several ways to set up multi-node clusters locally, but Minikube is not the best choice for this purpose. Instead, you can use tools like [Kind](https://kind.sigs.k8s.io/) or K3d, which are specifically designed for creating multi-node Kubernetes clusters in a more straightforward manner.


## Minikube

To simulate a multi-node cluster with Minikube, you can start multiple Minikube instances with different profiles. Here's how to do it:
```bash
minikube start --nodes 3 -p multinode-demo
```

Below is a guide to simulate a multi-node cluster with Minikube:

- Simulating Multi-Node Clusters with Minikube
- Start the First Node (Control Plane):

### Start the first node (control plane) with a unique profile name
```bash
minikube start --profile=node1
```

Start Additional Nodes (Worker Nodes): For each additional node, use a unique profile name:

```bash
minikube start --profile=node2
minikube start --profile=node3
```

Configure kubectl Contexts: Minikube creates separate contexts for each profile. You can switch between them using:

```bash
kubectl config use-context node1
kubectl config use-context node2
kubectl config use-context node3
```

Networking Between Nodes: Minikube nodes are isolated by default. To enable communication, you would need to configure networking manually, which can be complex. Alternatively, consider using a tool like Kind or K3d for a more seamless multi-node experience.


# Kind

**Use Kind for Multi-Node Clusters**

If you need a true multi-node Kubernetes cluster locally, Kind (Kubernetes IN Docker) is a better option. Here's how to create a multi-node cluster with [Kind](https://kind.sigs.k8s.io/):

```bash
# Download the latest Kind binary
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
# Make it executable
chmod +x ./kind
# Move it to your user's executable PATH
sudo mv ./kind /usr/local/bin/kind
```

**Create a Multi-Node Cluster**: 

Create a configuration file (e.g., kind-config.yaml):
```yaml

kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  - role: worker
```
Save the above configuration in a file named `kind-cluster-config.yaml`. This configuration defines a cluster with one control plane node and two worker nodes.


Then, create the cluster:
```bash
# Create the Kind cluster using the configuration file
kind create cluster --config ./05-kind-multinode/kind-cluster-config.yaml
```

Verify the Cluster
```bash
# Check the cluster information
kubectl cluster-info
# List the nodes in the cluster
kubectl get nodes
```
# Rename Nodes in Kind
To rename a node in Kind, you can use the `kind get nodes` command to list the nodes and then use `kubectl label` to add a label to the node. However, renaming nodes directly is not supported in Kind. Instead, you can create a new cluster with the desired node names.

kubectl label node <node-name> new-name=<desired-name>

kubectl label node gnx-cluster-worker node-role.kubernetes.io/worker=worker


kubectl label node gnx-cluster-worker new-name=gnx-cluster-worker1


Minikube is excellent for single-node setups, but for multi-node clusters, Kind or K3d are more practical and efficient. Let me know if you'd like further assistance! 😊