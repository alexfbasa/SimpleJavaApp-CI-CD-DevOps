# Walkthrough of DevOps CI/CD Course

## Overview

This DevOps project aims to deploy an application across three different target environments: Virtual Machines (VM),
Docker containers, and Kubernetes clusters. The course covers the setup of Continuous Integration/Continuous
Deployment (CI/CD) pipelines using GitHub, Jenkins, Maven, Tomcat, Docker, Ansible, and Kubernetes.

![DevOps CI/CD](../images/desired_stack.png)

## VM Deployment

1. **Setting up Jenkins Server:**

- Initial environment setup starts with Jenkins server installation.
- Configuring Maven and Git for code management.
- Setting up Tomcat server and integrating it with Jenkins.

2. **CI/CD Pipeline for VM:**

- Creating a Jenkins job to build and deploy the application on a Tomcat server.
- Testing the deployment to ensure functionality.

## Docker Container Deployment

1. **Docker Environment Setup:**

- Configuring Docker environment using GitHub, Jenkins, Maven, and Docker.
- Writing Dockerfile, creating an image, and deploying a container on Docker host.

2. **CI/CD Pipeline for Docker:**

- Integrating Docker host with Jenkins.
- Creating a Jenkins job to build and deploy the application on a Docker container.

## Ansible Deployment on Container

1. **Ansible Integration:**

- Setting up Ansible server and integrating it with Docker host.
- Using Ansible Playbooks to create Docker images and containers.

2. **CI/CD Pipeline for Ansible on Docker:**

- Creating a Jenkins job to build code with Ansible and deploy it on a Docker container.
- Committing artifacts to Docker Hub using Ansible Playbooks.

## Kubernetes Cluster Deployment

1. **Kubernetes Setup on AWS:**

- Setting up Kubernetes on AWS using Elastic Kubernetes Service (EKS).
- Writing pod, service, and deployment manifest files for Kubernetes.

2. **Integrating Kubernetes with Ansible:**

- Integrating Kubernetes with Ansible for automation.

3. **CI/CD Pipeline for Kubernetes:**

- Creating a Jenkins job to build code with Ansible and deploy it on a Kubernetes cluster.

## Step-by-step

### Setup Jenkins

For this lab we will be using a Jenkins as docker environment, which has already defined configurations and tools. It
will
be running inside a vm host provided by Vagrant.

```commandline
docker run -d -p 8080:8080 --env JENKINS_ADMIN_ID=admin -v /var/run/docker.sock:/var/run/docker.sock --env JENKINS_ADMIN_PASSWORD=password112rr -p 50000:50000 alexsimple/jenkins_jcasc:v3
```

### Setup local Kubernetes

Setup
This lab utilizes Vagrant to provision two nodes, a Master and Worker. Most of the needed tools will be installed in
both hosts by running Vagrant.

```commandline
cd provisioning
vagrant up
```

Run the kubernetes initialization command on only on MASTER node:

```commandline
kubeadm reset
sudo kubeadm init --apiserver-advertise-address=100.0.0.1 --pod-network-cidr=10.244.0.0/16 
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config 
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Now run the latest step on MASTER
After the master of the cluster is ready to handle jobs and the services are running, for the purpose of making
containers accessible to each other through networking, we need to set up the network for container communication.

Copy from /provisioning/files/kube-flannel.yml into Master node and apply it. You can run it by vagrant scp using
vagrant-scp plugin:


```commandline
vagrant plugin install vagrant-scp 
vagrant scp files/kube-flannel.yml master:/tmp
vagrant ssh master
cd /tmp
kubectl apply -f kube-flannel.yml
```

Note down kubeadm join command which we are going to use from worker node to join the master node using token. (Note : -
Following command will be different for you, do not try copy the following command)

DO NOT execute the referred command in the worker node yet.

```text
kubeadm join 100.0.0.1:6443 --token {{YOUR_TOKEN}} --discovery-token-ca-cert-hash sha256:{{YOUR_HASH}}
```
That might take some minutes to leave the Master ready, you can check it by:

```commandline
kubectl get nodes
```

Now you can execute the kubeadm join in the WORKER node: 
```commandline
sudo kubeadm reset
sudo kubeadm join 100.0.0.1:6443 --token {{YOUR_TOKEN}} --discovery-token-ca-cert-hash sha256:{{YOUR_HASH}}
```
That command might take a bit longer to connect in the Master node.

