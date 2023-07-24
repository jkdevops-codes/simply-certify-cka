#####   A. Upgrade Primary Control-plane  ######

#1. Drain control plane
k drain m-1  --ignore-daemonsets

#2 Check next minor realse to install
sudo apt update
sudo apt-cache madison kubeadm

#3. Install latest kubeadm
sudo apt-mark unhold kubeadm && \
sudo apt-get update && sudo apt-get install -y kubeadm=1.27.3-00 && \
sudo apt-mark hold kubeadm

#4. Upgrade kubeadm
sudo kubeadm upgrade plan
sudo kubeadm upgrade apply v1.27.3

#5. Upgrade kubelet and kubeclt
sudo apt-mark unhold kubelet kubectl && \
sudo apt-get update && sudo apt-get install -y kubelet=1.27.3-00 kubectl=1.27.3-00 && \
sudo apt-mark hold kubelet kubectl

#6. Restart kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet

#7.uncordon control plane
k uncordon m-1





#####   B. Upgrade Secondary  Control-plane  ######
#1. Drain control plane
k drain m-2  --ignore-daemonsets

#2. Install latest kubeadm
sudo apt-mark unhold kubeadm && \
sudo apt-get update && sudo apt-get install -y kubeadm=1.27.3-00 && \
sudo apt-mark hold kubeadm

#4. Upgrade kubeadm
sudo kubeadm upgrade apply

#5. Upgrade kubelet and kubeclt
sudo apt-mark unhold kubelet kubectl && \
sudo apt-get update && sudo apt-get install -y kubelet=1.27.3-00 kubectl=1.27.3-00 && \
sudo apt-mark hold kubelet kubectl

#6. Restart kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet

#7.uncordon control plane
k uncordon m-2



#####   C. Upgrade Worker  Node  ######
#1. Drain control plane
k drain w-1  --ignore-daemonsets

#2. Install latest kubeadm
sudo apt-mark unhold kubeadm && \
sudo apt-get update && sudo apt-get install -y kubeadm=1.27.3-00 && \
sudo apt-mark hold kubeadm

#4. Upgrade kubeadm
sudo kubeadm upgrade node

#5. Upgrade kubelet and kubeclt
sudo apt-mark unhold kubelet kubectl && \
sudo apt-get update && sudo apt-get install -y kubelet=1.27.3-00 kubectl=1.27.3-00 && \
sudo apt-mark hold kubelet kubectl

#6. Restart kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet

#7.uncordon control plane
k uncordon w-1