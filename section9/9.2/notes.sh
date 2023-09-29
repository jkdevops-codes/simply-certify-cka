#Create labels to a worker node
#Delete: https://medium.com/kubernetes-tutorials/learn-how-to-assign-pods-to-nodes-in-kubernetes-using-nodeselector-and-affinity-features-e62c437f3cf8
k label nodes worker-1 nodetype=highcpu
k label nodes worker-1 disktype=ssd


#NodeSelector
cat <<EOF >> node-selector.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
  nodeSelector:
    disktype: ssd
EOF

#Remove a Label
k label nodes worker-1 disktype-
