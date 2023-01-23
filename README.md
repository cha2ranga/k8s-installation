
Rocky Linux - K8s Installation

Create a Kubernetes cluster with [@Rocky Linux minimum](https://rockylinux.org/download) installation on the vsphere environment. 

This cluster consists of a single master node and two worker nodes. we will use [@kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/) to initialize the cluster. 

At a later phase, let's add the [@metallb](https://metallb.universe.tf/installation/) for the load balancer IP range and [@dashboard](https://github.com/kubernetes/dashboard) for GUI. 

The basic idea here is to map fundamental container components like compute, network, and storage (at a later phase) together. 

Compute - CRI (Container Runtime Interface) [@containerd](https://github.com/containerd/containerd)

Network - CNI (Container Network Interface) [@calico](https://github.com/projectcalico/calico)

Storage - CSI (Container Storage Interface) [@Dell PowerStore](https://github.com/dell/csi-powerstore) ## Futuer Blog




## Network Diagram

![Diagram1](https://github.com/cha2ranga/k8s-installation/blob/main/images/diagram1.jpg)


## VMs Installation 

Setup VMs with minimum installation (2vCPU, 4GB Memory, 30GB Disks)
Once installation is finished, set up static IPs (preferred) for all three VMs. 
Then upgrade the OS to the latest patch versions for all three VMs. 
```bash
  yum install -y wget
  yum update -y && reboot
```
Once nodes are back online, set up/etc/hosts file as follows. If you have proper DNS in the environment, feel free to follow 

Since we are following non-production deployment, add the host file entries. 
```bash
 cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
172.27.3.101    master
172.27.3.102    worker1
172.27.3.103    worker2
```

## Configure passwordless SSH
Configure ssh-key files
### on master 
```bash
ssh-keygen
```
Once ssh-key is ready, you can copy the key to worker1 and worker2
```bash
ssh-copy-id root@worker1
ssh-copy-id root@worker2
```
Now from the master node, you will be able to ssh into both worker nodes without a password. 




## VM prepreration for k8s installation

Multiple parameters need to configure before we start k8s installation. Here we will use [@containerd](https://github.com/containerd/containerd) as a CRI.

The rest of the prerequisites, like swap configuration, additional packages, firewall, and additional kernel modules, will be configured using basic bash scripts. 

You can manually edit the scripts if you want to adjust a specific version of the k8s installation. Define a particular version number. 
Otherwise, this installation will follow the latest version of k8s packages. 

Create a directory and download scripts

```bash
cd ~ && mkdir k8s_installation && cd k8s_installation
wget https://raw.githubusercontent.com/cha2ranga/k8s-installation/main/scripts/1_k8s_install_part1.bash
wget https://raw.githubusercontent.com/cha2ranga/k8s-installation/main/scripts/2_k8s_install_part2.bash
chmode +x 1_k8s_install_part1.bash
chmode +x 2_k8s_install_part2.bash
```

## Run Script 1_k8s_install_part1.bash

## Manually configure containerd settings
Change the value of cgroup driver "SystemdCgroup = false" to "SystemdCgroup = true". This setting will enable the systemd cgroup driver for the containerd container runtime.
```bash
vim /etc/containerd/config.toml
```
![containerd configuration](https://github.com/cha2ranga/k8s-installation/blob/main/images/containerd1.jpg)

