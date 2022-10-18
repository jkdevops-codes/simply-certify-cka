#:::::: HOS VM ::::::#
#1. Check OS Detail of the host VM
uname -a

#2. Check IP details of host VM
> ip a
#Check the ens4 host VM network ip and note there is no any docker based network. 


#:::::: DOCKER INSTALLATION  ::::::#
#3. Install Docker 
sudo apt update
sudo apt install docker.io
docker info #Check runtime details runc and containerd
#Note: If there is a permissin issue, execute following command to solve the issue
sudo chmod 666 /var/run/docker.sock


#:::::: RUN NGINX CONTAINER   ::::::#

#4. Pull the nginx image from the container registry
docker pull nginx
docker images
#Note the image ID

#5. Run the nginx Image, so that you will get the running container in the host VM
docker run -it -d <image_id> 

#6. SSH to running isolated container's Linux terminal
docker ps #copy the container id 
docker exec -it -d  <Container ID>  sh

#7. Check container OS
uname -a 
cat /etc/os-release

#8. Check PID
apt update
apt-get install -y procps
ps aux

#9. Check Network Detail
apt install -y iproute2
ip addr

#:::::: RUN NGINX CONTAINER   ::::::#

Similarly pull and run redis container image and check the following
PID, Network, OS