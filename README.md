# K8s walkthrough

This repository contains useful resources about how to setting up a Kubernetes cluster.

The solution is designed to be run on an Ubuntu 24.04.1 LTS VM using Windows Subsystem for Linux (WSL2).
You can use it both on Linux machine or on a VM running on a cloud provider like AWS, Azure, or GCP.

# Introduction

You can setup the cluster by using different methods, like using KiNd, Minikube, MicroK8s or any other Kubernetes cluster setup distribution.

The walkthrough will use a demo application based on the Genocs Library, which provides a set of services to see how the application can be deployed and managed in a Kubernetes environment. The application also includes the use of an internal API gateway along with a set of other services like: identity service, products service, orders service, and notifications service.

The walkthrough includes setting up helm for managing Kubernetes applications and ArgoCD for managing the application deployment.

A solution based on Dapr will also be provided. 

Dapr is a portable, event-driven runtime that makes it easy for developers to build resilient, stateless, and stateful applications that run on the cloud and edge.

The solution will cover the entire lifecycle of a Kubernetes application, from development to deployment and management.
Setup of other resources are also in place as external MongoDB database, RabbitMQ message broker, Nginx AGIC for ingress, an a bunch of Kubernetes resources like Secrets and ConfigMaps and so on.


## Introduction

![Genocs Library Architecture](./assets/Genocs-Library-gnx-architecture.drawio.png)

The solution is based on the following requirements:

- Setup windows subsystem for Linux (WSL2) with Ubuntu 24.04.1 LTS
- Use KiNd to create a Kubernetes cluster
- Use minikube to create a Kubernetes cluster
- Use MicroK8s to create a Kubernetes cluster
- Create a Kubernetes cluster with 1 nodes onto Ubuntu Ubuntu 24.04.1 LTS VM
- Use Nginx AGIC to expose the web application to the internet
- Use Genocs Library to build the services
- Deploy an application based on Genocs Library 
- Use Helm chart to define the application deployment
- Use ArgoCD to manage the application deployment
- Use an internal API gateway to route the traffic to the web services
- Use an internal identity service to manage the user authentication
- Connect to an external MongoDB database
- Connect to an external RabbitMQ message broker 
- Use a Secret to store the database credentials
- Use a ConfigMap to store the web application configuration
- Use a Persistent Volume to store the data
- Use a Persistent Volume Claim to claim the Persistent Volume
- Setup a Kubernetes dashboard to monitor the cluster
- Setup a Kubernetes dashboard to start automatically when the cluster starts
- Setup ArgoCD to manage the application deployment
- Use Helm chart to install MongoDB and RabbitMQ
- Setup AGIC to espose MongoDB and RabbitMQ to the internet
- Setup AGIC to expose ArgoCD dashboard to the internet 

Todo:
- Use Let's Encrypt to secure the web application
- Use LXC runtime to create multiple nodes


# Documentation
This repository contains the following documentation:


## Table of Contents

| Topic | Description |
|---------|-------------|
| [01-INSTALL_WSL2](./docs/01-INSTALL_WSL2.md) | Step-by-step guide to install WSL2 on Windows. |
| [02-INSTALL_MINIKUBE](./docs/02-INSTALL_MINIKUBE.md) | Step-by-step guide to setup a Kubernetes cluster using Minikube. |
| [03-INSTALL_KIND](./docs/03-INSTALL_KIND.md) | Step-by-step guide to setup a Kubernetes cluster using KiNd. |
| [04-INSTALL_MICROK8S](./docs/04-INSTALL_MICROK8S.md) | Step-by-step guide to setup a Kubernetes cluster using MicroK8s. |
| [05-INSTALL_HELM](./docs/05-INSTALL_HELM.md) | Step-by-step guide to install Helm on the Kubernetes cluster. |
| [06-INSTALL_DAPR](./docs/06-INSTALL_DAPR.md) | Step-by-step guide to install Dapr on the Kubernetes cluster. |
| [07-INSTALL_RABBITMQ](./docs/07-INSTALL_RABBITMQ.md) | Step-by-step guide to install RabbitMQ on the Kubernetes cluster. |
| [08-INSTALL_MONGODB](./docs/08-INSTALL_MONGODB.md) | Step-by-step guide to install MongoDB on the Kubernetes cluster. |
| [09-INSTALL_NGINX_INGRESS](./docs/09-INSTALL_NGINX_INGRESS.md) | Step-by-step guide to install Nginx Ingress Controller on the Kubernetes cluster. |
| [10-INSTALL_ARGOCD](./docs/10-INSTALL_ARGOCD.md) | Step-by-step guide to install ArgoCD on the Kubernetes cluster. |
| [11-INSTALL_GENOCS_LIBRARY](./docs/11-INSTALL_GENOCS_LIBRARY.md) | Step-by-step guide to install Genocs Library on the Kubernetes cluster. |


TO BE CONTINUED...


# Miscellaneous

References and resources used in this project:
- [Genocs Library](https://genocs.com/library/)

- [Windows Subsystem for Linux (WSL2)](https://docs.microsoft.com/en-us/windows/wsl/install)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
- [KiNd Documentation](https://kind.sigs.k8s.io/docs/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [MicroK8s](https://microk8s.io/) - A lightweight Kubernetes distribution
- [Dapr](https://dapr.io/docs/) - Dapr Documentation
- [Kubernetes Ingress Documentation](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [Kubernetes Secrets Documentation](https://kubernetes.io/docs/concepts/configuration/secret/)
- [Kubernetes Dashboard Documentation](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)
- [Helm Documentation](https://helm.sh/docs/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/en/stable/)
- [Nginx Ingress Controller Documentation](https://kubernetes.github.io/ingress-nginx/)
- [Cert-Manager Documentation](https://cert-manager.io/docs/)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)
- [MongoDB Documentation](https://docs.mongodb.com/)
- [RabbitMQ Documentation](https://www.rabbitmq.com/documentation.html)
- [linux container virtualization](https://linuxcontainers.org/)
