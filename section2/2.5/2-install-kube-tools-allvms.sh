##Install kubeadm, kubelet, kubectl 
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl


#Better run below two lines one by one.
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

#curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
#echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

#Update the OS again
sudo apt-get update

# If you want to install Specific version, first find the avalaible versions and then install the version you want, else igonre the version to install recent version
# For learning purpose I am going to list and install particular version 

#apt list -a kubeadm | head -5

KUBECOMPNENTS_VERSION=1.28.7-1.1
sudo apt-get install -y kubelet=${KUBECOMPNENTS_VERSION}
sudo apt-get install -y kubectl=${KUBECOMPNENTS_VERSION} 
sudo apt-get install -y  kubeadm=${KUBECOMPNENTS_VERSION}

sudo apt-mark hold kubelet #prevent updating the packages automatically
sudo apt-mark hold kubectl
sudo apt-mark hold kubeadm