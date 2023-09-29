#Question
#You are working with a Kubernetes cluster set up using kubeadm, consisting of one control plane and a worker node. ​
#The cluster is experiencing an issue where a pod named "pod-1" with the nginx image is not running. ​
#Upon investigation, you suspect that the cluster's control plane is configured to use cgroupfs as the cgroup driver. ​
#Your task is to check and change the control plane's cgroup driver to systemd. ​
#Additionally, verify the worker node kubelet configuration and change it to use systemd as the cgroup driver if required.​
#Ensure that the "pod-1" with the nginx image starts running successfully.​

#1. Check the logs of pod-1
k describe po pod-1


#2. go to master-1
k edit configmap  kubelet-config -n kube-system
#change cgroupfs to systemd

#3. Go to worker node and follow the steps to change cgroup driver

#Drain the worker-1  using 
k drain worker-1 --ignore-daemonsets
#Stop the kubelet using systemctl stop kubelet
systemctl stop kubelet

#Stop the container runtime
sudo systemctl stop containerd
#Modify the container runtime cgroup driver to systemd
sudo sed -i -r 's/SystemdCgroup =.*/SystemdCgroup = true/' /etc/containerd/config.toml

#Set cgroupDriver: systemd in /var/lib/kubelet/config.yaml
vim /var/lib/kubelet/config.yaml

#Start the container runtime
sudo systemctl restart containerd

#Start the kubelet using 
sudo systemctl start kubelet

#Uncordon the node using 
kubectl uncordon worker-1




