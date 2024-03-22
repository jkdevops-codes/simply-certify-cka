# ......
# Execute following commands to all the nodes except lb
# .......

##Install kubeadm, kubelet, kubectl 
sudo apt-get install -y apt-transport-https ca-certificates curl
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update

# If you want to install Specific version, first find the avalaible versions and then install the version you want, else igonre the version to install recent version
# For learning purpose I am going to list and install particular version 
#apt list -a kubeadm | head -5




KUBECOMPNENTS_VERSION=1.29.3-1.1
sudo apt-get install -y kubelet=${KUBECOMPNENTS_VERSION} kubeadm=${KUBECOMPNENTS_VERSION} kubectl=${KUBECOMPNENTS_VERSION}
sudo apt-mark hold kubelet kubeadm kubectl #prevent updating the packages automatically

