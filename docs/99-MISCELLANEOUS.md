# Certification exam questions

This section contains the questions from the certification exam.

```bash
# Create and Run a pod
kubectl run <pod_name> --image=<image_name> --drry-run=client -o yaml > pod.yaml

# Create a deployment
kubectl create deployment <deployment_name> --image=<image_name>

# Create a service
kubectl expose <service_name> ... TO BE CONTINED

# Network Commands
following commands are useful for managing network interfaces, routes, and IP addresses in a Linux environment as bash commands:

# Check the current network interfaces
ip link

# Check the current network interfaces
ip addr

# Add a new network interface
ip addr add <ip_address>/<subnet_mask> dev <interface_name>

# Check the current routing table
ip route

# Add a static route
ip route add <destination_network> via <gateway_ip>

# Check if IP forwarding is enabled
cat /proc/sys/net/ipv4/ip_forward

# DNS configration

# Check the current name resolution configuration
cat /etc/hosts

# Check the current DNS configuration
cat /etc/resolv.conf

# Check the current name service switch configuration
cat /etc/nsswitch.conf

# **Domain names**

# Check the current domain name
hostname -d

kubectl create secret tls webhook-server-tls --cert="webhook-server.crt" --key="webhook-server.key" -n <namespace_name>

# kubectl for kubeapiserver

# Check the current kube-apiserver configuration

# This command will show the kube-apiserver help options,
# which can be useful for understanding its configuration and available flags.
kubectl exec -it kube-apiserver-controlplane -n kube-system -- kube-apiserver -h

# This command will show the kube-apiserver configuration file.
# Edit the kube-apiserver configuration file
vi /etc/kubernetes/manifests/kube-apiserver.yaml
```
