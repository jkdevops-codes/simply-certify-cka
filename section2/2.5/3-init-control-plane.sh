#https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/configure-cgroup-driver/
KUBECOMPNENTS_VERSION=1.28.7-1.1
cat <<EOF | tee kubeadm-config.yaml
kind: ClusterConfiguration
apiVersion: kubeadm.k8s.io/v1beta3
kubernetesVersion: ${KUBECOMPNENTS_VERSION}
---
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
cgroupDriver: systemd  
EOF

sudo kubeadm init --config kubeadm-config.yaml

#Note: You can run the same ignoring preflight errors 
#sudo kubeadm init --config kubeadm-config.yaml --ignore-preflight-errors all

#Note: If you face issue on detecting runtime 
#sudo rm -fr  /var/run/docker-shim.sock
#sudo rm -fr  /var/run/docker.sock

#Note: If you want to generate a token again, use the following command. 
#kubeadm token create --print-join-command


####### INSTALL CNI CALICO  ############ 
#Please refer https://docs.tigera.io/calico/3.25/getting-started/kubernetes/self-managed-onprem/onpremises
wget https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml
kubectl  apply -f calico.yaml

# Check the file and check the Pod CIDR Range defined



####### INSTALL CNI WEAVENET  ############ 
#Please refer https://www.weave.works/docs/net/latest/kubernetes/kube-addon/
# We are here weavenet CNI which is having pod cidr range : 10.32.0.0/12
#wget https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
#kubectl apply -f weave-daemonset-k8s.yaml


# Check the file and check the Pod CIDR Range defined



#podCIDR=192.168.0.0/24
#- --service-cluster-ip-range=10.96.0.0/12






