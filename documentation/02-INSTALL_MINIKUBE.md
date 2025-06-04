# How to Install Kubernetes on WSL2 using Minikube
This guide will help you set up Kubernetes on your Windows machine using WSL2 and Minikube.

## Prerequisites

Please ensure you have wsl2 installed on your Windows machine. If you haven't done so, follow the instructions in the [Install WSL2](01-INSTALL_WSL2.md) guide.



### Install Docker, Minikube, and Kubectl
Update the package database and install prerequisites
```bash
# Update the package database and install prerequisites
sudo apt update && sudo apt upgrade -y
# Install prerequisites for Docker
sudo apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
```

Install Docker
```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Verify that you now have the key with the fingerprint
#sudo apt-key fingerprint 0EBFCD88

# Add the Docker repository to APT sources
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
```

Update the package database with the Docker packages from the newly added repo
```bash
sudo apt-get update -y
sudo apt-get install -y docker-ce 
sudo usermod -aG docker $USER && newgrp docker
```

# Install Minikube

Follow these steps to install Minikube on Ubuntu running on WSL2:

```bash
# Download the latest Minikube binary
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

# Make it executable
chmod +x ./minikube

# Move it to your user's executable PATH
sudo mv ./minikube /usr/local/bin/

# Set the driver version to Docker
minikube config set driver docker
```

### Install Kubectl

To install `kubectl`, the command-line tool for interacting with Kubernetes clusters, follow these steps:

```bash
# Download the latest kubectl binary
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Make it executable
chmod +x ./kubectl

# Move it to your user's executable PATH
sudo mv ./kubectl /usr/local/bin/

# Verify the installation
kubectl version --client
```

### Start Minikube
Open your WSL2 Ubuntu terminal and run the following command to start 
```bash
# Start Minikube with the Docker driver
minikube start --driver=docker
```

It will take a couple of minutes depending on your internet connection.

>If it shows you an error, it could be possible to your WSL2 is out of date as systemd was introduced in Sept-2022.
>
>To fix that
>In powershell type wsl.exe — update and try running minikube start after restarting wsl
> Once your minikube starts working, type:
```bash
minikube status
```
>You should see something like this:
```plaintext
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```

### Configure Kubectl to Use Minikube
To configure `kubectl` to use Minikube, run the following command:

```bash
minikube update-context
```

This command will set the current context to Minikube in your `kubectl` configuration.
```bash
kubectl config use-context minikube

# Start minikube again to enable kubectl in it
minikube start

# Check the status of Minikube (get running pods all namespaces)
kubectl get pods -A
```
You'll see something.
```plaintext
NAMESPACE     NAME                               READY   STATUS    RESTARTS   AGE
kube-system   coredns-78fcd69978-5j4q7           1/1     Running   0          2m
kube-system   etcd-minikube                      1/1     Running   0          2m
kube-system   kube-apiserver-minikube            1/1     Running   0          2m
kube-system   kube-controller-manager-minikube   1/1     Running   0          2m
kube-system   kube-proxy-5j4q7                   1/1     Running   0          2m
kube-system   kube-scheduler-minikube            1/1     Running   0          2m
kube-system   storage-provisioner                1/1     Running   0          2m
```

You have successfully installed and configured Kubernetes on the local system using WSL2.

### Step 6: Setup and Accessing the Kubernetes Dashboard

To set up and access the Kubernetes dashboard, follow these steps:
```bash
minikube addons enable dashboard
```
This command will enable the dashboard addon in Minikube, and it will start automatically when you run `minikube start`.
This command will ensure that the dashboard is enabled every time you start Minikube.

To access the Kubernetes dashboard, you can run the following command:

```bash
minikube dashboard
```
This command will open the Kubernetes dashboard in your default web browser.


### Stopping and Restarting Minikube
To stop Minikube, you can run:

```bash
minikube stop
```

To restart Minikube, you can run:

```bash
minikube start
```

### Deleting Minikube
To delete your Minikube cluster, you can run:

```bash
minikube delete
```
This command will remove the Minikube cluster and all associated resources.

### Updating Minikube
To update Minikube to the latest version, you can run:

```bash
minikube update-check
minikube update
```
This command will check for updates and apply them if available.

### Uninstalling Minikube
To uninstall Minikube, you can run the following command:

```bash
sudo rm -rf /usr/local/bin/minikube
```
This command will remove the Minikube binary from your system.

### Uninstalling Docker
To uninstall Docker, you can run the following commands:

```bash
sudo apt-get purge -y docker-ce docker-ce-cli containerd.io
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
```

## Running Minikube as a Service (Start at Startup)

To have Minikube start automatically as a service when your WSL2 Ubuntu instance starts, you can create a systemd service:

1. Create a new systemd service file for Minikube:

   ```bash
   sudo nano /etc/systemd/system/minikube.service
   ```

2. Add the following content to the file:

   ```ini
   [Unit]
   Description=Minikube Kubernetes Cluster
   After=docker.service
   Requires=docker.service
   
   [Service]
   Type=simple
   User=<your-username>
   ExecStart=/usr/local/bin/minikube start --driver=docker
   ExecStop=/usr/local/bin/minikube stop
   Restart=on-failure
   
   [Install]
   WantedBy=default.target
   ```
   Replace `<your-username>` with your actual Ubuntu username.

3. Reload systemd and enable the service:
   
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable minikube.service
   ```

4. Start the Minikube service:
   ```bash
   sudo systemctl start minikube.service
   ```

5. Check the status of the Minikube service:
   ```bash
   sudo systemctl status minikube.service
   ```

Now, Minikube will start automatically with your WSL2 Ubuntu session.