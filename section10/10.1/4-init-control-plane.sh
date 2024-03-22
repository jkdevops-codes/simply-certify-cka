# ......
# Go to first control plan and execute following commands. 
# If we initialize the first master noded succussfully, we will get kubeadm based generated join commands for master nodes and worker nodes seperatley.
# .......

## Generate a certkey
CERT_KEY=$(kubeadm  certs certificate-key)

## Generate the configuration file 
#https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/configure-cgroup-driver/
# March-2024 : 
#Please note I have used version in my video training and don't use that in the below configuration file.
cat <<EOF | tee kubeadm-config.yaml
kind: ClusterConfiguration
apiVersion: kubeadm.k8s.io/v1beta3
---
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
cgroupDriver: systemd  
EOF
cat <<EOF | tee kubeadm-config.yaml
kind: ClusterConfiguration
apiVersion: kubeadm.k8s.io/v1beta3
controlPlaneEndpoint: "lb:6443"
---
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
cgroupDriver: systemd  
---
apiVersion: kubeadm.k8s.io/v1beta3
kind: InitConfiguration
certificateKey: "${CERT_KEY}"
EOF


#Bootstrap the cluster using kubeadm
sudo kubeadm init --upload-certs --config kubeadm-config.yaml


#install Calico CNI
wget https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml
kubectl  apply -f calico.yaml


##Troubleshoot
# sudo systemctl status kubelet
# sudo journalctl -xeu kubelet
# sudo crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock ps -a | grep kube | grep -v pause
# sudo crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock logs CONTAINERID

