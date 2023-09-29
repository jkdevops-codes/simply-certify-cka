###########     COPY CA FILES TO NODE FROM CONTROL PLANE    ##########

#1. Go to Control Plane and copy the CA files (ca.key, ca.crt)
cd $HOME/
sudo cp /etc/kubernetes/pki/ca.key . #copy the certificates to your home directory
sudo cp /etc/kubernetes/pki/ca.crt .
sudo chown $(id -un):$(id -gn) ca.key #change the ownership to current user
sudo chown $(id -un):$(id -gn) ca.crt

NODE="worker-3" 
ZONE="us-west4-b"

echo "Y" | gcloud compute scp ca.key  $(id -un)@${NODE}:\~ --zone=${ZONE} #copy the files to NODE
echo "Y" |  gcloud compute scp ca.crt  $(id -un)@${NODE}:\~ --zone=${ZONE}
#Note : If you have permission issue when copy a file, please run 'gcloud auth login' in control plane



###########     CREATE KUBECONFIG FILE    ##########

#1 Go to worker node and create a private key and sign it by ca.key
NODE="worker-3" 
openssl genrsa -out ${NODE}.key 2048
openssl req -new -key ${NODE}.key -out ${NODE}.csr -subj="/CN=system:node:${NODE}/O=system:nodes"
openssl x509 -req -CA ca.crt -CAkey ca.key  -CAcreateserial -days 365 -in ${NODE}.csr -out ${NODE}.crt


#2. Copy the files ${NODE}.key, ${NODE}.crt, ca.crt, ca.key files to /etc/kubernetes/pki

#3. Create kubeconfig file for the Node. lets name it kubelet.conf 

#Method 1:

API_SERVER="https://10.240.0.200:6443" 
cat <<EOF >> kubelet.conf
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: $(cat ca.crt | base64)
    server: ${API_SERVER}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    namespace: default
    user: system:node:${NODE}
  name: default-context
current-context: default-context
kind: Config
users:
- name: system:node:${NODE}
  user:
    client-certificate: $(cat ${NODE}.crt | base64)
    client-key: $(cat ${NODE}.key | base64)
EOF


# Method 2:
API_SERVER="https://10.240.0.200:6443" 
kubectl config set-cluster kubernetes --certificate-authority=ca.crt --embed-certs=true --server=${API_SERVER} --kubeconfig=kubelet.conf
kubectl config set-credentials system:node:${NODE} --client-certificate=${NODE}.crt --client-key=${NODE}.key --embed-certs=true --kubeconfig=kubelet.conf
kubectl config set-context default --cluster=kubernetes --user=system:node:${NODE} --kubeconfig=kubelet.conf
kubectl config use-context default --kubeconfig=kubelet.conf



#----------------- Start kubelet from worker-3 and troubleshoot
#1. Check the kubelet status​
sudo systemctl status kubelet

#2. Start kubelet and check logs
sudo systemctl start kubelet
sudo systemctl status kubelet

tail -f /var/log/syslog
journalctl -xeu kubelet

#3. Add the config file 
sudo mkdir -p /var/lib/kubelet
cat <<EOF | sudo tee /var/lib/kubelet/config.yaml
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/etc/kubernetes/pki/ca.crt"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
cgroupDriver: systemd
clusterDNS:
  - "10.96.0.10"
resolvConf: "/run/systemd/resolve/resolv.conf"
EOF

#3. Copy ca.crt to required location 
sudo mkdir -p /etc/kubernetes/pki/
sudo cp ca.crt  /etc/kubernetes/pki/

#4. Copy the kubelet.conf file to /etc/kubernetes/
sudo cp kubelet.conf  /etc/kubernetes/

#4. Add container runtime details to  kubeadm-flags.env
sudo vim /var/lib/kubelet/kubeadm-flags.env
KUBELET_KUBEADM_ARGS="--container-runtime=remote --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock --pod-infra-container-image=registry.k8s.io/pause:3.8"


#Remove node from control plane. Go to master-1 and execute the following 
NODE="worker-3"
kubectl drain ${NODE}  --ignore-daemonsets --delete-local-data
kubectl delete node ${NODE}



###########    INSTALL CNI PLUGIN BINARIES AND VERIFY CNI CONFIGURATION    ##########
#Note:
#* CNI relative paths are /opt/cni/bin where all CNI binaries located and /etc/cni/net.d where CNI plugin configuration located
#* Once you install containerd /etc/cni/net.d path will be automatically generated but empty
#* When we install kubelet /opt/cni/bin folder will be created with CNI supported files


#1. Check the folder /etc/cni/net.d

#2. Install the Calico CNI plugin binaries
#Refer: https://projectcalico.docs.tigera.io/getting-started/kubernetes/hardway/install-cni-plugin

#curl -L -o /opt/cni/bin/calico https://github.com/projectcalico/cni-plugin/releases/download/v3.20.6/calico-amd64
#sudo chmod 755 /opt/cni/bin/calico
#curl -L -o /opt/cni/bin/calico-ipam https://github.com/projectcalico/cni-plugin/releases/download/v3.20.6/calico-ipam-amd64
#sudo chmod 755 /opt/cni/bin/calico-ipam


#3. Restart kubelet
#sudo systemctl restart kubelet
#sudo systemctl status kubelet

#4. Check Logs
#tail -f /var/log/syslog




#Install the plugin
#curl -L -o /opt/cni/bin/calico https://github.com/projectcalico/cni-plugin/releases/download/v3.20.6/calico-amd64
#chmod 755 /opt/cni/bin/calico
#curl -L -o /opt/cni/bin/calico-ipam https://github.com/projectcalico/cni-plugin/releases/download/v3.20.6/calico-ipam-amd64
#chmod 755 /opt/cni/bin/calico-ipam


#1. Check the worker node worker-1 which was joined to kubeadm based cluster using kubeadm join command
#    Check the kubeconfig file
#    Check the node certifcate
#openssl x509 -in /var/lib/kubelet/pki/kubelet-client-current.pem -text -noout
#        [Subject: O = system:nodes, CN = system:node:worker-1]

#3. Copy the  Certificate Authority files ( /etc/kubernetes/pki/ca.crt, /etc/kubernetes/pki/ca.key ) from master to worker node which we are going to join to cluster. In my case worker-2

#4. Create a private key and sign it by ca.key

#1. CNI relative paths re /opt/cni/bin where all CNI binaries located and /etc/cni/net.d where CNI plugin configuration located
#2. Once you install containerd /etc/cni/net.d path will be automatically generated but empty
#3. When we install kubelet /opt/cni/bin folder will be created with CNI supported files
  
