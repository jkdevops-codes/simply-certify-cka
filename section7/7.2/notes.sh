#Delete PVs and PVCs that you have already created
k patch pvc pvc-one -p '{"metadata":{"finalizers":null}}'
k patch pvc pvc-two -p '{"metadata":{"finalizers":null}}'
k patch pv nfs-volume-1 -p '{"metadata":{"finalizers":null}}'
k patch pv nfs-volume-2 -p '{"metadata":{"finalizers":null}}'

k delete --all pv,pvc --force --grace-period=0




cat <<EOF >> storageclass-nfs.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: managed-nfs-storage
provisioner: k8s-sigs.io/nfs-subdir-external-provisioner # or choose another name, must match deployment's env PROVISIONER_NAME'
parameters:
  archiveOnDelete: "false"
EOF


cat <<EOF >> pvc-three.yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-three
spec:
  storageClassName: managed-nfs-storage
  accessModes:
  - ReadWriteMany
  resources:
   requests:
     storage: 500Mi
EOF

#Create a pod using PVC
cat <<EOF >> pvc-pod-sc.yaml
apiVersion: v1
kind: Pod
metadata:
  name: pvc-pod-sc
spec:
  containers:
    - name: pvc-pod-sc
      image: nginx
      volumeMounts:
        - mountPath: "/usr/share/nginx/html"
          name: pv-storage
  volumes:
    - name: pv-storage
      persistentVolumeClaim:
        claimName: pvc-three
EOF