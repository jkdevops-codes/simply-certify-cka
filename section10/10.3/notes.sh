#:::::::::: ETCD Backup :::::::::: #

#1. Go through ETCD server and certificates
ls /etc/kubernetes/pki/etcd/
#Cluster CA Certificate
/etc/kubernetes/pki/etcd/ca.crt
#Health Check Client certificate
/etc/kubernetes/pki/etcd/healthcheck-client.crt
#Health Check Key
/etc/kubernetes/pki/etcd/healthcheck-client.key

#2. Install etcd client
sudo apt  install etcd-client


#3. Find the EndPoint of the cluster 
sudo vim /etc/kubernetes/manifests/kube-apiserver.yaml
 - --etcd-servers=https://127.0.0.1:2379

#4. Check ETCD  Health
sudo ETCDCTL_API=3 etcdctl --endpoints https://127.0.0.1:2379 \
--cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt \
--key=/etc/kubernetes/pki/etcd/healthcheck-client.key \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
endpoint health

#5. Find the ETCD Cluster Status
sudo ETCDCTL_API=3 etcdctl --endpoints https://127.0.0.1:2379 \
--cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt \
--key=/etc/kubernetes/pki/etcd/healthcheck-client.key \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
--write-out=table  endpoint status

#5. Find the ETCD Members List
sudo ETCDCTL_API=3 etcdctl --endpoints https://127.0.0.1:2379 \
--cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt \
--key=/etc/kubernetes/pki/etcd/healthcheck-client.key \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
--write-out=table  member list


#6. Create and run some pods before taking etcd snapshot
k run prod-pod1 --image=nginx 
k run prod-pod2 --image=nginx 
k run prod-pod3 --image=nginx 
k run prod-pod4 --image=nginx 

#7. Take etcd snapshot 
sudo mkdir  /var/etcd-backup
sudo ETCDCTL_API=3 etcdctl --endpoints https://127.0.0.1:2379 \
--cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt \
--key=/etc/kubernetes/pki/etcd/healthcheck-client.key \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
snapshot save /var/etcd-backup/snapshot.db


#5. Check the ETCD snapshot status
sudo ETCDCTL_API=3 etcdctl --endpoints https://127.0.0.1:2379 \
--cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt \
--key=/etc/kubernetes/pki/etcd/healthcheck-client.key \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
--write-out=table snapshot status /var/etcd-backup/snapshot.db


#6. Now delete all the pods 
kubectl delete pods --all

#7. move the etcd data directory contents
sudo mv  /var/lib/etcd/ ~/
sudo rm -fr   /var/lib/etcd

#8. Check the pods 
k get po 


#9. Restore Cluster using  ETCD snapshot
sudo ETCDCTL_API=3 etcdctl --endpoints https://127.0.0.1:2379 \
--cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt \
--key=/etc/kubernetes/pki/etcd/healthcheck-client.key \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
snapshot restore  /var/etcd-backup/snapshot.db --data-dir /var/lib/etcd

#10. Restore Cluster using  ETCD snapshot