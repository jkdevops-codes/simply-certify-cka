# ......
# Execute following commands to all the nodes except lb
# .......

##Install kubeadm, kubelet, kubectl 
sudo apt-get install -y apt-transport-https ca-certificates curl
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update

# If you want to install Specific version, first find the avalaible versions and then install the version you want, else igonre the version to install recent version
# For learning purpose I am going to list and install particular version 
#apt list -a kubeadm | head -5




KUBECOMPNENTS_VERSION=1.26.5
sudo apt-get install -y kubelet=${KUBECOMPNENTS_VERSION}-00 kubeadm=${KUBECOMPNENTS_VERSION}-00 kubectl=${KUBECOMPNENTS_VERSION}-00
sudo apt-mark hold kubelet kubeadm kubectl #prevent updating the packages automatically

