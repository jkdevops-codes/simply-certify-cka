############# KUBEADM MASTER SETUP  ############# 

sudo apt-get update

#1. Disable linux swap and remove any existing swap partitions
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab


#2. Enable OS to support CNI Netwoking 
#Link: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system


#3. Install a Container Runtime ( Containerd )
#Link: https://kubernetes.io/docs/setup/production-environment/container-runtimes/

sudo apt-get update
echo "Y" | sudo apt install containerd

cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Setup required sysctl params, these persist across reboots.
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml


sudo systemctl daemon-reload
sudo systemctl enable containerd
sudo systemctl restart containerd
sudo systemctl status containerd


#ps -ef | grep containerd


##Install kubeadm, kubelet, kubectl 
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo apt-get install -y bash-completion binutils #Optional

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update

# If you want to install Specific version, first find the avalaible versions and then install the version you want, else igonre the version to install recent version
# For learning purpose I am going to list and install particular version 

#apt list -a kubeadm | head -5

KUBECOMPNENTS_VERSION=1.22.4
sudo apt-get install -y kubelet=${KUBECOMPNENTS_VERSION}-00 kubeadm=${KUBECOMPNENTS_VERSION}-00 kubectl=${KUBECOMPNENTS_VERSION}-00
sudo apt-mark hold kubelet kubeadm kubectl #prevent updating the packages

#echo "y" | sudo kubeadm reset
#sudo rm -fr /etc/cni/net.d
#sudo rm -fr $HOME/.kube/config
#echo "Y" | sudo apt-get purge kubeadm kubectl kubelet kubernetes-cni 
#sudo rm -fr /opt/cni/bin
#sudo systemctl daemon-reload
#sudo rm -fr /etc/kubernetes
#sudo rm -fr  /var/lib/kubelet/
#sudo rm -fr /etc/systemd/system/kubelet.service.d/
#journalctl -xeu kubelet
#sudo rm  -fr  /var/lib/kubelet/config.yaml
#sudo rm -fr /var/lib/kubelet/kubeadm-flags.env
#sudo systemctl daemon-reload
# kubeadm-config.yaml
cat <<EOF | tee kubeadm-config.yaml
kind: ClusterConfiguration
apiVersion: kubeadm.k8s.io/v1beta3
kubernetesVersion: v${KUBECOMPNENTS_VERSION}
---
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
cgroupDriver: systemd  
#cgroupfs
EOF

sudo kubeadm init --config kubeadm-config.yaml --ignore-preflight-errors all

#Note: If you face issue on detecting runtime 
#sudo rm -fr  /var/run/docker-shim.sock
#sudo rm -fr  /var/run/docker.sock


kubeadm token create --print-join-command


curl https://docs.projectcalico.org/manifests/calico.yaml -O
kubectl apply -f calico.yaml


podCIDR=192.168.0.0/24
- --service-cluster-ip-range=10.96.0.0/12


master-1 = 10.128.0.14
worker-1 = 10.128.0.15
worker-2= 10.128.0.16

nginx = 192.168.0.72 (worker 1)
redis = 192.168.0.195 (worker2)
httpd = 192.168.0.193 (worker1)
alpine = 192.168.0.194(worker2)

redis-deploy = 192.168.0.196 (worker-2)
redis-deploy (svc) = 10.104.167.68 (cluster ip)

nginx-deploy (svc )=10.100.96.19
nginx-deploy (pod) = 192.168.0.73    (worker-1)


master pod cidr = 192.168.0.0/24
master1 = tunl0 = 192.168.0.128/32
worker 1 = tunl0 = 192.168.0.64/32
worker 2 = tunl0 = 192.168.0.192/32



