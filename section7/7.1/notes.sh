###### INSTALL NFS SERVER #######
#SSH to the instance where NFS server to be installed
sudo apt update && sudo apt -y upgrade
sudo apt install -y nfs-server
mkdir /data
sudo chmod -R 777 /data

sudo vim /etc/exports
#Add the following line at the end of the file content
#/data/ *(rw,sync,no_root_squash,subtree_check)
/data  *(rw,sync,no_subtree_check,no_root_squash,no_all_squash,insecure)

sudo systemctl enable --now nfs-server
sudo exportfs -rav

#Check if the NFS server is working properly.
#Go to a worker node.

sudo apt install -y nfs-common
showmount -e master-1


cat <<EOF >> nfs-volume-1.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-volume-1
spec:
  accessModes:
    - ReadWriteOnce
  capacity:
    storage: 2Gi
  persistentVolumeReclaimPolicy: Delete
  volumeMode: Filesystem
  nfs:
    server: master-1
    path: /data
    readOnly: false
EOF


cat <<EOF >> nfs-volume-2.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nfs-volume-2
spec:
  accessModes:
    - ReadWriteOnce
  capacity:
    storage: 1Gi
  persistentVolumeReclaimPolicy: Delete
  volumeMode: Filesystem
  nfs:
    server: master-1
    path: /data
    readOnly: false
EOF


#Create two PVC with different storage requirement
cat <<EOF >> pvc-one.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-one
spec:
  accessModes:
  - ReadWriteOnce
  resources:
   requests:
     storage: 200Mi
EOF


cat <<EOF >> pvc-two.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-two
spec:
  accessModes:
  - ReadWriteOnce
  resources:
   requests:
     storage: 1200Mi
EOF


#Create a pod using PVC
cat <<EOF >> pvc-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: pvc-pod
spec:
  containers:
    - name: pvc-pod
      image: nginx
      volumeMounts:
        - mountPath: "/usr/share/nginx/html"
          name: pv-storage
  volumes:
    - name: pv-storage
      persistentVolumeClaim:
        claimName: pvc-one
EOF