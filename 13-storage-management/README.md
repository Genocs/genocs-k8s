# Storage Management

This directory contains Kubernetes storage management examples and configurations for the Genocs K8s project.

## Overview

The `storage.yaml` file demonstrates various Kubernetes storage concepts and resources including storage classes, persistent volumes, persistent volume claims, config maps, and pods with different volume mount configurations.

## Components

### 1. StorageClass (`gnx-sc`)

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: gnx-sc
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
```

- **Purpose**: Defines a storage class for manual volume provisioning
- **Provisioner**: Uses `kubernetes.io/no-provisioner` for static provisioning
- **Binding Mode**: `WaitForFirstConsumer` delays volume binding until a pod uses the PVC

### 2. ConfigMap (`webapp-config-map`)

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: webapp-config-map
data:
  APP_COLOR: "darkblue"
  APP_OTHER: "disregard"
```

- **Purpose**: Stores configuration data as key-value pairs
- **Usage**: Provides environment variables for applications
- **Data**: Contains application-specific configuration settings

### 3. Pod with HostPath Volume (`webapp`)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: webapp
spec:
  containers:
    - name: webapp
      image: kodecloud/event-simulator
      volumeMounts:
        - mountPath: log
          name: log-volume
  volumes:
    - name: log-volume
      hostPath:
        path: /var/log/webapp
  envFrom:
    - configMapRef:
        name: webapp-config-map
```

- **Purpose**: Demonstrates hostPath volume mounting and ConfigMap environment injection
- **Volume Type**: Uses hostPath to mount a directory from the host node
- **Environment**: Loads environment variables from the ConfigMap
- **Mount Path**: Mounts the host directory to `/log` inside the container

### 4. PersistentVolume (`pv-log`)

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-log
spec:
  capacity:
    storage: 100Mi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /pv/log
```

- **Purpose**: Defines a cluster-level storage resource
- **Capacity**: 100Mi of storage
- **Access Mode**: `ReadWriteMany` allows multiple pods to read/write simultaneously
- **Reclaim Policy**: `Retain` keeps data after PVC deletion
- **Storage Type**: Uses hostPath for local storage

### 5. PersistentVolumeClaim (`claim-log-1`)

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: claim-log-1
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 50Mi
  storageClassName: gnx-sc
```

- **Purpose**: Requests storage from the cluster
- **Access Mode**: `ReadWriteOnce` allows one pod to read/write at a time
- **Storage Request**: Requests 50Mi of storage
- **Storage Class**: Uses the custom `gnx-sc` storage class

### 6. Pod with PVC (`webapp-claim`)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: webapp-claim
spec:
  containers:
    - name: webapp-claim
      image: kodecloud/event-simulator
      volumeMounts:
        - mountPath: log
          name: log-volume
  volumes:
    - name: log-volume
      persistentVolumeClaim:
        claimName: claim-log-1
```

- **Purpose**: Demonstrates persistent volume usage through PVC
- **Volume Source**: Uses PersistentVolumeClaim instead of direct volume
- **Mount Path**: Mounts the persistent volume to `/log` inside the container

## Usage

To deploy these resources to your Kubernetes cluster:

```bash
kubectl apply -f storage.yaml
```

To verify the deployment:

```bash
# Check storage class
kubectl get storageclass gnx-sc

# Check persistent volumes
kubectl get pv pv-log

# Check persistent volume claims
kubectl get pvc claim-log-1

# Check pods
kubectl get pods webapp webapp-claim

# Check config map
kubectl get configmap webapp-config-map
```

## Notes

1. **Storage Class**: The `gnx-sc` storage class uses manual provisioning, requiring pre-created persistent volumes
2. **Access Modes**: The PV supports `ReadWriteMany` but the PVC requests `ReadWriteOnce`
3. **Capacity Mismatch**: The PV provides 100Mi but PVC only requests 50Mi
4. **HostPath Limitations**: HostPath volumes are node-specific and not suitable for multi-node clusters in production

## Best Practices

- Use appropriate storage classes for your environment
- Consider using dynamic provisioning in production
- Match access modes between PV and PVC
- Use network-attached storage for multi-node clusters
- Implement proper backup strategies for persistent data