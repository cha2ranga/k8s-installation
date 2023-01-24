##$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
##$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$     Manual config     $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
##$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
echo ""
echo "@@@@@@@@@@@@@@@@@@@@ Manually edit /etc/containerd/config.toml and set SystemdCgroup = True @@@@@@@@@@@"
echo ""
### /etc/containerd/config.toml
###Change the value of cgroup driver "SystemdCgroup = false" to "SystemdCgroup = true". This will enable the systemd cgroup driver for the containerd container runtime.
##
###    [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
###      ...
###      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
###        SystemdCgroup = true
##
##
read -p "Do you want to proceed? (yes/no) " yn

case $yn in
        yes ) echo ok, we will proceed;;
        no ) echo exiting...;
                exit;;
        * ) echo invalid response;
                exit 1;;
esac

#### Enable containerd service
echo ""
echo "!!!!!!!!!!!!!! containerd version and status !!!!!!!!!!!!!"
rpm -qa |grep -i containerd
systemctl enable --now containerd
systemctl is-enabled containerd
##systemctl status containerd
##
##
##
################################ Install K8s Packages ###############################
##
#dnf install kubelet kubeadm kubectl --disableexcludes=kubernetes
##Install Kubernetes Latest version
#
echo ""
echo "!!!!!!!!!!!!!!!!!!!!!!!!!! Installing K8s latest packages. !!!!!!!!!!!!!!!!!!!!!!"
echo ""
# If you want to install specific version, follow below format
#yum install -y kubelet-1.22.1-0 kubeadm-1.22.1-0 kubectl-1.22.1-0 --disableexcludes=kubernetes
#
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

# verify
rpm -qa |grep -i kube

########################### Enable Kubelet ###################################
systemctl enable --now kubelet



########################### iscsi / multipath config ###################################
echo ""
echo "!!!!!!!!!!!!!!!!!!!!!!!!!! Enabling iSCSI services for CSI !!!!!!!!!!!!!!!!!!!!!!"
echo ""
systemctl start multipathd.service iscsi.service iscsid.service

systemctl enable multipathd.service iscsi.service iscsid.service

mpathconf --enable --user_friendly_names y


echo ""
echo "!!!!!!!!!!!!!!!!!!!!!!!!!! Loaded iSCSI Services and multipath !!!!!!!!!!!!!!!!!!!!!!"
echo ""


