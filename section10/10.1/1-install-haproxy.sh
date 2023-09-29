# ......
# Execute following commands to lb VM only
# .......

#Install haproxy
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install haproxy -y


#Edit haproxy configuration file
sudo vi /etc/haproxy/haproxy.cfg

## Add following lines in the end of the file
frontend fe-apiserver
   bind 0.0.0.0:6443
   mode tcp
   option tcplog
   default_backend be-apiserver

backend be-apiserver
   mode tcp
   option tcplog
   option tcp-check
   balance roundrobin
   default-server inter 10s downinter 5s rise 2 fall 2 slowstart 60s maxconn 250 maxqueue 256 weight 100

       server m-1 10.20.0.11:6443 check
       server m-2 10.20.0.12:6443 check
##

#Restart haproxy
sudo systemctl restart haproxy
sudo systemctl status haproxy

#Check if haproxy working properly
nc -v localhost 6443

