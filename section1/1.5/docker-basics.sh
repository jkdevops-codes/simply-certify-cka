#:::::: HOS VM ::::::#
#1. Check IP details of host VM
> ip a
#Check the ens4 host VM network ip and note there is no any docker based network. 


#:::::: DOCKER INSTALLATION  ::::::#
#2. Install Docker 
sudo apt update
sudo apt install docker.io
docker info #Check runtime details runc and containerd
#Note: If there is a permissin issue, execute following command to solve the issue
sudo chmod 666 /var/run/docker.sock


#:::::: RUN NGINX CONTAINER   ::::::#

#3. Pull the nginx image from the container registry
docker pull nginx
docker images
#Note the image ID

#4. Run the nginx Image, so that you will get the running container in the host VM
docker run -it -d  <image_id> 

#5. SSH to running isolated container's Linux terminal
docker ps #copy the container id 
docker exec -it   <Container ID>  sh

#6. Check container OS
uname -a 
cat /etc/os-release

#7. Check Network Detail
apt install -y iproute2
ip addr

#:::::: RUN REDIS CONTAINER   ::::::#
Similarly pull and run redis container image and check the network


#Run a nginx container with port-forward option
docker run -d  -p 8080:80 nginx
