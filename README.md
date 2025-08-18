# Kubernetes Walkthrough

This repository contains comprehensive resources for setting up and managing Kubernetes clusters.

The solution is designed to run on Ubuntu 24.04.1 LTS using Windows Subsystem for Linux (WSL2).
It can also be used on native Linux machines or VMs running on cloud providers like AWS, Azure, or GCP.

## Overview

This walkthrough demonstrates how to set up a Kubernetes cluster using various methods including Kind, Minikube, MicroK8s, or other Kubernetes distributions.

The walkthrough features a demo application based on the Genocs Library, which provides a set of microservices to demonstrate how applications can be deployed and managed in a Kubernetes environment. The application includes an internal API gateway along with several services: identity service, products service, orders service, and notifications service.

The walkthrough covers setting up Helm for managing Kubernetes applications and ArgoCD for managing application deployments.

A solution based on Dapr is also provided. Dapr is a portable, event-driven runtime that makes it easy for developers to build resilient, stateless, and stateful applications that run on the cloud and edge.

The solution covers the entire lifecycle of a Kubernetes application, from development to deployment and management. Additional resources include external MongoDB database, RabbitMQ message broker, Nginx Ingress Controller, and various Kubernetes resources such as Secrets, ConfigMaps, and more.

## Architecture

![Genocs Library Architecture](./assets/Genocs-Library-gnx-architecture.drawio.png)

## Requirements

The solution is based on the following requirements:

- Set up Windows Subsystem for Linux (WSL2) with Ubuntu 24.04.1 LTS
- Create a Kubernetes cluster using Kind, Minikube, or MicroK8s
- Create a Kubernetes cluster with 1 node on Ubuntu 24.04.1 LTS VM
- Use Nginx Ingress Controller to expose the web application to the internet
- Use Genocs Library to build the services
- Deploy an application based on Genocs Library
- Use Helm charts to define the application deployment
- Use ArgoCD to manage the application deployment
- Use an internal API gateway to route traffic to the web services
- Use an internal identity service to manage user authentication
- Connect to an external MongoDB database
- Connect to an external RabbitMQ message broker
- Use Secrets to store database credentials
- Use ConfigMaps to store web application configuration
- Use Persistent Volumes to store data
- Use Persistent Volume Claims to claim Persistent Volumes
- Set up a Kubernetes dashboard to monitor the cluster
- Configure the Kubernetes dashboard to start automatically when the cluster starts
- Set up ArgoCD to manage the application deployment
- Use Helm charts to install MongoDB and RabbitMQ
- Configure Ingress to expose MongoDB and RabbitMQ to the internet
- Configure Ingress to expose the ArgoCD dashboard to the internet

## Future Enhancements

- Use Let's Encrypt to secure the web application
- Use LXC runtime to create multiple nodes

## General Concepts

You can use different methods to set up a Kubernetes cluster, including Kind, Minikube, MicroK8s, or other Kubernetes distributions.

Here is a brief overview of the different methods:

- **Kind (Kubernetes in Docker)**: A tool for running local Kubernetes clusters using Docker container "nodes". It is useful for testing and development purposes.
- **Minikube**: A tool that makes it easy to run Kubernetes locally. It runs a single-node Kubernetes cluster inside a VM on your laptop or in the cloud.
- **MicroK8s**: A lightweight, production-grade Kubernetes distribution that runs on Linux. It is designed for IoT and edge devices, but can also be used for local development.

For more information about these methods, refer to the [Kubernetes documentation](https://kubernetes.io/docs/home/).

## Documentation

This repository contains the following documentation:

### Table of Contents

| Topic                                                            | Description                                                                      |
| ---------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| [01-INSTALL_WSL2](./docs/01-INSTALL_WSL2.md)                     | Step-by-step guide to install WSL2 on Windows                                    |
| [02-INSTALL_MINIKUBE](./docs/02-INSTALL_MINIKUBE.md)             | Step-by-step guide to set up a Kubernetes cluster using Minikube                 |
| [03-INSTALL_KIND](./docs/03-INSTALL_KIND.md)                     | Step-by-step guide to set up a Kubernetes cluster using Kind                     |
| [04-INSTALL_MICRO_K8S](./docs/04-INSTALL_MICRO_K8S.md)           | Step-by-step guide to set up a Kubernetes cluster using MicroK8s                 |
| [05-INSTALL_HELM](./docs/05-INSTALL_HELM.md)                     | Step-by-step guide to install Helm on the Kubernetes cluster                     |
| [06-INSTALL_DAPR](./docs/06-INSTALL_DAPR.md)                     | Step-by-step guide to install Dapr on the Kubernetes cluster                     |
| [07-INSTALL_RABBITMQ](./docs/07-INSTALL_RABBITMQ.md)             | Step-by-step guide to install RabbitMQ on the Kubernetes cluster                 |
| [08-INSTALL_MONGODB](./docs/08-INSTALL_MONGODB.md)               | Step-by-step guide to install MongoDB on the Kubernetes cluster                  |
| [09-INSTALL_NGINX_INGRESS](./docs/09-INSTALL_NGINX_INGRESS.md)   | Step-by-step guide to install Nginx Ingress Controller on the Kubernetes cluster |
| [10-INSTALL_ARGOCD](./docs/10-INSTALL_ARGOCD.md)                 | Step-by-step guide to install ArgoCD on the Kubernetes cluster                   |
| [11-INSTALL_GENOCS_LIBRARY](./docs/11-INSTALL_GENOCS_LIBRARY.md) | Step-by-step guide to install Genocs Library on the Kubernetes cluster           |

_More documentation coming soon..._

## References and Resources

- [Genocs Library](https://genocs.com/library/)
- [Windows Subsystem for Linux (WSL2)](https://docs.microsoft.com/en-us/windows/wsl/install)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
- [Kind Documentation](https://kind.sigs.k8s.io/docs/)
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
- [Linux Container Virtualization](https://linuxcontainers.org/)
