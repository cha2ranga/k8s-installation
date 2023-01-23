Rocky Linux - K8s Installation

Create a Kubernetes cluster with [@Rocky Linux minimum](https://rockylinux.org/download) installation on the vsphere environment. 

This cluster consists of a single master node and two worker nodes. we will use [@kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/) to initialize the cluster. 

At a later phase, let's add the [@metallb](https://metallb.universe.tf/installation/) for the load balancer IP range and [@dashboard](https://github.com/kubernetes/dashboard) for GUI. 

Basic idea here to map a basic container components like compute, network and storage (at later phase) to together. 

Compute - CRI (Container Runtime Interface)

Network - CNI (Container Network Interface)

Storage - CSI (Container Storage Interface)




## Network Diagram

![Diagram1](https://github.com/cha2ranga/k8s-installation/blob/main/images/diagram1.jpg)


