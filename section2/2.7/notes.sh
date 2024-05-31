###########     COPY CA FILES TO NODE FROM CONTROL PLANE    ##########

#1. Go to Control Plane and copy the CA files (ca.key, ca.crt)
cd $HOME/
#copy the certificates to your home directory
sudo cp /etc/kubernetes/pki/ca.key . 
sudo cp /etc/kubernetes/pki/ca.crt .
#change the ownership to current user
sudo chown $(id -un):$(id -gn) ca.key 
sudo chown $(id -un):$(id -gn) ca.crt

NODE="worker-3" 
ZONE="us-west4-b"

echo "Y" | gcloud compute scp ca.key  $(id -un)@${NODE}:\~ --zone=${ZONE}
echo "Y" |  gcloud compute scp ca.crt  $(id -un)@${NODE}:\~ --zone=${ZONE}
#copy the files to NODE
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

## SESSNIO 2.7 CONTIUE #########
#1. Check the status of kubelet and restart the kubelet
sudo systemctl status kubelet
sudo systemctl restart kubelet
sudo systemctl status kubelet

#Check the log and find what went wrong
journalctl -xeu kubelet
tail -f /var/log/syslog

#2. We will get container runtime address error, to solve that,
#add the container runtime parameters  /lib/systemd/system/kubelet.service and restart the kubelet again 
sudo vim /lib/systemd/system/kubelet.service
#......
[Unit]
Description=kubelet: The Kubernetes Node Agent
Documentation=https://kubernetes.io/docs/home/
Wants=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/bin/kubelet --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock
Restart=always
StartLimitInterval=0
RestartSec=10

[Install]
WantedBy=multi-user.target
#......

sudo systemctl daemon-reload
sudo systemctl restart kubelet
sudo systemctl status kubelet

#Check the logs 
tail -f /var/log/syslog


#3. Now we will get CNI initialization error, But without solving that I am going to copy the
#kubelet.conf file I created to  /etc/kubernetes/kubelet.conf
#Note: kubeadm will solve the CNI issue and we dont want to solve that
sudo cp kubelet.conf /etc/kubernetes/kubelet.conf

#4. Now add the  kubelet.conf reference to kubelet.service and restart kubelet
sudo vim /lib/systemd/system/kubelet.service

#......
[Unit]
Description=kubelet: The Kubernetes Node Agent
Documentation=https://kubernetes.io/docs/home/
Wants=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/bin/kubelet --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock --kubeconfig=/etc/kubernetes/kubelet.conf 
Restart=always
StartLimitInterval=0
RestartSec=10

[Install]
WantedBy=multi-user.target
#......


sudo systemctl daemon-reload
sudo systemctl restart kubelet
sudo systemctl status kubelet


#5. Check if the worker node is joined to control plane
kubectl get nodes #run in the control planes master-1

#6. Check the logs 
tail -f /var/log/syslog


#7. Now we will get Control Group Driver based error. Lets set the kubelet to support systemd as cgroup driver.

#7.1: Create a KubeletConfiguration called config.yaml in /var/lib/kubelet/config.yaml
cat <<EOF | sudo tee /var/lib/kubelet/config.yaml
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
cgroupDriver: systemd
EOF

#7.2: Modify the kubelet.service to refer the config file
sudo vim /lib/systemd/system/kubelet.service

#......
[Unit]
Description=kubelet: The Kubernetes Node Agent
Documentation=https://kubernetes.io/docs/home/
Wants=network-online.target
After=network-online.target

[Service]

ExecStart=/usr/bin/kubelet --container-runtime-endpoint=unix:///var/run/containerd/containerd.sock --kubeconfig=/etc/kubernetes/kubelet.conf --config=/var/lib/kubelet/config.yaml
Restart=always
StartLimitInterval=0
RestartSec=10

[Install]
WantedBy=multi-user.target
#......


sudo systemctl daemon-reload
sudo systemctl restart kubelet
sudo systemctl status kubelet

#Check the logs   
tail -f /var/log/syslog


#8. Check the master node if the worker node is joined
kubectl get nodes


#9. Remove  the /var/lib/kubelet/config.yaml and restart kubelet, so that worker node will goto Not Ready status
sudo rm -fr /var/lib/kubelet/config.yaml
sudo systemctl restart kubelet

#10. Recreate /var/lib/kubelet/config.yaml with more options
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

#Also copy the ca.crt file to /etc/kubernetes/pki/ca.crt 
sudo mkdir -p /etc/kubernetes/pki/
sudo cp ca.crt /etc/kubernetes/pki/ca.crt 

#Restart the kubelet 
sudo systemctl restart kubelet
tail -f /var/log/syslog

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
