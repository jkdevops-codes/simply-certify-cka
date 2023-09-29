#Question: 
#1. Create a worker node-based directory (/var/web-content) and mount it to a PV called task-pv-volume with storage capacity 5Gi​
#2.Create a PVC task-pvc-volume in the namespace yellow and allow 500Mi storage ​
#3. Attach the PVC to a pod called task-pv-pod with the image httpd and mount the volume to container path /usr/local/apache2/htdocs/ ​



#Answer:

#1. Go to Worker Node and create the directory /var/web-content
    sudo mkdir -p /var/web-content
    sudo chmod -R 777 /var/web-content
#2. In Kubernetes Documentation, Search for  "Configure a Pod to Use a PersistentVolume for Storage"
#3
cat <<EOF >> task-pv-volume.yml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: task-pv-volume
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/var/web-content"
EOF
k apply -f task-pv-volume.yml

#5.
cat <<EOF >> task-pvc-volume.yml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: task-pvc-claim
  namespace: yellow
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
EOF

k apply -f task-pvc-volume.yml


#6.
cat <<EOF >>  task-pv-pod.yml
apiVersion: v1
kind: Pod
metadata:
  name: task-pv-pod
  namespace: yellow
spec:
  volumes:
    - name: task-pv-storage
      persistentVolumeClaim:
        claimName: task-pvc-claim
  containers:
    - name: task-pv-container
      image: httpd
      ports:
        - containerPort: 80
          name: "http-server"
      volumeMounts:
        - mountPath: "/usr/local/apache2/htdocs/"
          name: task-pv-storage
EOF
k apply -f task-pv-pod.yml



