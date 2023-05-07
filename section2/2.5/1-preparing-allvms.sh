############# PREPAIR ALL HOSTS INCLUDING CONTROL PLANE AND NODES TO INSTALL KUBEADM  ############# 
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
echo "Update OS......"
sudo apt-get update

#1. Disable linux swap and remove any existing swap partitions
echo "Disable Linux Swap......"
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab


#2. Enable required Kernel Modules to  make sure CNI Pugins and Continer Runtime to work properly 
# https://kubernetes.io/docs/setup/production-environment/container-runtimes/

echo "Enable  Required Kernel Modules and Parameters......"

cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/containerd.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1 
EOF

# Apply sysctl params without reboot
sudo sysctl --system


#3. Install Containerd
#Refer: https://github.com/containerd/containerd/blob/main/docs/getting-started.md

CONTAINERD_VERSION="1.6.20"
wget https://github.com/containerd/containerd/releases/download/v${CONTAINERD_VERSION}/containerd-${CONTAINERD_VERSION}-linux-amd64.tar.gz
sudo tar Cxzvf /usr/local containerd-${CONTAINERD_VERSION}-linux-amd64.tar.gz

#4. Setup Containerd Service
wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
sudo mv  containerd.service /lib/systemd/system
sudo systemctl daemon-reload
sudo systemctl enable --now containerd
#sudo systemctl status containerd

#5 Install runc.
#To check recent version Refer: https://github.com/opencontainers/runc/tags  
#Note: containerd does not include runc and we have to install seperately. But containerd.io fro docker included runc as well.
RUNC_VERSION="1.1.7"
wget https://github.com/opencontainers/runc/releases/download/v${RUNC_VERSION}/runc.amd64
sudo install -m 755 runc.amd64 /usr/local/sbin/runc

#6 Configure Containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

echo "Enable Systemd Control Group on Containerd......."
sudo sed -i -r 's/SystemdCgroup =.*/SystemdCgroup = true/' /etc/containerd/config.toml

#4. Configuring the systemd cgroup driver
#Link: https://kubernetes.io/docs/setup/production-environment/container-runtimes/

#To use the systemd cgroup driver in /etc/containerd/config.toml with runc, set

#[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
#  ...
#  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
#    SystemdCgroup = true
#The systemd cgroup driver is recommended if you use cgroup v2.

echo "Restarting containerd service......"
sudo systemctl restart containerd
sudo systemctl enable containerd
#sudo systemctl status containerd
#sudo systemctl daemon-reload
#ps -ef | grep containerd


