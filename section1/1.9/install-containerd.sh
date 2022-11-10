#We used docker tool to understand the communication between each containers and VMs. We know that user interact with docker CLI and that communicate with containerd runtime interface to sawn a container. Containerd is now completely decoupled project and can install seperately. Lets see how we can install containerd only without installing docker tool.

#. Install a Container Runtime ( Containerd )
#Link: https://kubernetes.io/docs/setup/production-environment/container-runtimes/


#Specially in kubernetes, when you are using contianer runtime interface, you must enable kernel  modules 'overlay' and 'br_netfilter' to let the VM iptables to view bridge network. So remember we have to add these kernel modules and also change few kernal paremeters to enable proper communication in kuberntes cluster based VMs. For CKA exam you will not asked to install containerd. but better we must know to check the containerd configuration file. OK let me install those kernel modules and comfigure required kernel parameters for learning. 

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

#Please note contianerd runtime interface definetly interface with Conrol Groups. WE already learned that countrol group is helping us to assign #resources such CPU and memory to a container.
#We know there are two major control group managers cgroupfs and systemd.
#We can configure containerd to use what control group manager if cgroupfs or systemd.  let me show that
#Lets open the confuration file locate in 


#Well we have done everything and now time to restart containerd service and enable it.

sudo systemctl restart containerd
sudo systemctl enable containerd
#sudo systemctl status containerd

#sudo systemctl daemon-reload


#Containerd CLI commands
#ctr image pull docker.io/library/hello-world:latest
#ctr image ls

#Please note for CKA exam we will never install containerd but we may need to work with deciding control group manager. for CKA exam we are allowed to #open kubernetes.io site and refer that when doing the exam. So I always match our lessons with kuberntes documentation pages and that will help you #familair where and what information located in which page. For containerd configuration you can go to the website and simply search for container runtime. 

#For CKA exam we must make sure container runtime interface and kubernetes components  use the same control group comanger, else there will be a conflict. 
#This is a good CKA point for trouble shooting purpose. We will do practical questions on  this in the later lesson.

#Lets see how we can enable  containerd to use systemd as cgroup driver

#Go to 
sudo vi /etc/containerd/config.toml

#containerd defualt cgroup driver is cgroupfs, I am changing that to systemd for learning purpose
#Find the line SystemdCgroup = false and change the value to true under the section 
#[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
SystemdCgroup = true

# Now restart the containerd
sudo systemctl restart containerd

#to verify config file
#sudo containerd config dump