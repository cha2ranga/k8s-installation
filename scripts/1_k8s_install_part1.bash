#SCRIPT
######################################################################
######################################################################

##Update the OS
#yum update -y

## Install packages


yum install epel-release yum-utils device-mapper-persistent-data lvm2 bash-completion tree screen wget elinks device-mapper-multipath iscsi-initiator-utils iscsi-initiator-utils-devel git bash-completion nfs-utils -y


echo ""
echo ""
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  Package configured !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo ""
echo ""

## Master Nodes
##  Protocol  Direction Port Range  Purpose Used By
##  -----------------------------------------------
##  TCP       Inbound   6443        Kubernetes API server All
##  TCP       Inbound   2379-2380   etcd server client API  kube-apiserver, etcd
##  TCP       Inbound   10250       Kubelet API Self, Control plane
##  TCP       Inbound   10259       kube-scheduler  Self
##  TCP       Inbound   10257       kube-controller-manager Self

# firewall-cmd --add-port=6443/tcp --permanent
# firewall-cmd --add-port=2379-2380/tcp --permanent
# firewall-cmd --add-port=10250/tcp --permanent
# firewall-cmd --add-port=10259/tcp --permanent
# firewall-cmd --add-port=10257/tcp --permanent
# firewall-cmd --reload
# firewall-cmd --list-all

## Worker Nodes
## Protocol  Direction Port Range  Purpose Used By
## --------------------------------------------------
## TCP       Inbound   10250       Kubelet API Self, Control plane
## TCP       Inbound   30000-32767 NodePort Services†  All
# firewall-cmd --add-port=10250/tcp --permanent
# firewall-cmd --add-port=30000-32767/tcp --permanent
# firewall-cmd --reload
# firewall-cmd --list-all

##Disable firewall starting from Kubernetes v1.19 onwards
systemctl disable firewalld --now


echo ""
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   firewall configured  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo ""
############################################ Load Modules ####################################
## Load modules (including additional Kernel modules for service mesh (istio))
modprobe overlay
modprobe br_netfilter
modprobe nf_nat
modprobe xt_REDIRECT
modprobe xt_owner
modprobe iptable_nat
modprobe iptable_mangle
modprobe iptable_filter


## letting ipTables see bridged networks
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
nf_nat
xt_REDIRECT
xt_owner
iptable_nat
iptable_mangle
iptable_filter
EOF


echo ""
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   module loading completed   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo ""


########################################### Network Config ####################################
# Create the systemctl params. Set up required sysctl params, these persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Apply config
sysctl --system
#sudo sysctl --system


echo ""
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!    Network config completed   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo ""

############################################ SWAP Config ####################################
### Disable swap
swapoff -a

##make a backup of fstab
cp -f /etc/fstab /etc/fstab.bak

##Remove swap from fstab
#sed -i '/swap/d' /etc/fstab
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Check the Swap
free -m


echo ""
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  Swap completed  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo ""

############################################ SELINUX Config ####################################
## Set SELinux in permissive mode (effectively disabling it)
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
sestatus



echo ""
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   SELINUX completed   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo ""


############################################ DNF Config ####################################
dnf install dnf-utils -y

# Add docker repo for containerd
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

# Add k8s repo
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF


# List repos
dnf repolist
dnf makecache


echo ""
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   K8s repo added  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo ""

######################################## Install CRI ###################################

dnf install containerd.io -y
rpm -qa |grep -i containerd

# After install backup orginal config files
mv /etc/containerd/config.toml /etc/containerd/config.toml.orig
containerd config default > /etc/containerd/config.toml



echo ""
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!    containerd installed   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo ""



##$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
##$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$     Manual config     $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
##$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
### /etc/containerd/config.toml
###Change the value of cgroup driver "SystemdCgroup = false" to "SystemdCgroup = true". This will enable the systemd cgroup driver for the containerd container runtime.
##
###    [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
###      ...
###      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
###        SystemdCgroup = true
##
##
#### Enable containerd service
##rpm -qa |grep -i containerd
##systemctl enable --now containerd
##systemctl is-enabled containerd
##systemctl status containerd
##
##
##
################################ Install K8s Packages ###############################
##
##dnf install kubelet kubeadm kubectl --disableexcludes=kubernetes
####Install Kubernetes
###yum install -y kubelet-1.22.1-0 kubeadm-1.22.1-0 kubectl-1.22.1-0 --disableexcludes=kubernetes
##
### verify
##rpm -qa |grep -i kube
##
############################# Enable Kubelet ###################################
##systemctl enable --now kubelet
##
##
##
############################# iscsi / multipath config ###################################
##systemctl start multipathd.service iscsi.service iscsid.service
##
##systemctl enable multipathd.service iscsi.service iscsid.service
##
##mpathconf --enable --user_friendly_names y
##
##

