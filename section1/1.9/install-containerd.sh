#We used docker tool to understand the communication between each containers and VMs. We know that user interact with docker CLI and that communicate with containerd runtime interface to sawn a container. Containerd is now completely decoupled project and can install seperately. Lets see how we can install containerd only without installing docker tool.

#. Install a Container Runtime ( Containerd )
#Link: https://kubernetes.io/docs/setup/production-environment/container-runtimes/


#Specially in kubernetes, when you are using contianer runtime interface, you must enable kernel  modules 'overlay' and 'br_netfilter' to let the VM iptables to view bridge network. So remember we have to add these kernel modules and also change few kernal paremeters to enable proper communication in kuberntes cluster based VMs. 
#OK let me install those kernel modules and comfigure required kernel parameters for learning.  

cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

#Note: You can check if kernal modules installed using following command
# lsmod | grep overlay
# lsmod | grep br_netfilter
# Follow below steps to load the kernal modules

# Setup required sysctl params, these persist across reboots.
cat <<EOF | sudo tee /etc/sysctl.d/containerd.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

#Now lets install containerd.
sudo apt-get update
echo "Y" | sudo apt install containerd

#Generate the default containerd config file and store to a location
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml

#Well we have done everything and now time to restart containerd service and enable it.

sudo systemctl restart containerd
sudo systemctl enable containerd
#sudo systemctl status containerd

#sudo systemctl daemon-reload


#Containerd CLI commands
#ctr image pull docker.io/library/hello-world:latest
#ctr image ls


#We know there are two major control group managers cgroupfs and systemd.
#We can configure containerd to use what control group manager if cgroupfs or systemd.  containerd default cgroup driver is cgroupfs
#For CKA exam we must make sure container runtime interface and kubernetes components  use the same control group comanger, else there will be a conflict. 
#This is a good CKA point for trouble shooting purpose. 
#Lets see how we can enable  containerd to use systemd as cgroup driver

#Lets edit the configuration file
sudo vi /etc/containerd/config.toml

#I am changing containerd defualt cgroup driver cgroupfs to systemd for learning purpose
#Find the line SystemdCgroup = false and change the value to true under the section 
#[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
SystemdCgroup = true

# Now restart the containerd
sudo systemctl restart containerd

#to verify config file
#sudo containerd config dump
