#Taint & Tolerance

# Taint:-
# Taint is a property of a node that prevents pods from scheduling inside that node, but it will schedule pods only if the pod tolerates the node taint.


# NoSchedule
# If we apply NoSchedule taint effect to a node then it will only allow the pods which have a toleration effect equal to NoSchedule. 
# If we apply NoSchedule taint to a node,  Already scheduled pods will be remiains running

# PreferNoSchedule
# If we apply NoSchedule taint effect to a node then it will try to allow the pods which have a toleration effect equal to PreferNoSchedule. 
# If there is only one worker node with the tain PreferNoSchedule, then it will allow pods to be scheduled

# NoExecute
# If we apply NoSchedule taint effect to a node then it will only allow the pods which have a toleration effect equal to NoSchedule. 
# If we apply NoSchedule taint to a node,  Already scheduled pods will be remiains running

#1: ShutDown all the Worker nodes

#2: Check the Taint of the Master Node
k describe node master-1
#Taint Effect is : NoSchedule
#Key used : node-role.kubernetes.io/control-plane

#3: Run a pod without toleration
cat <<EOF >> tolerate-master.yaml
apiVersion: v1
kind: Pod
metadata:
  name: tolerate-master
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
EOF

k apply -f  tolerate-master.yaml


#3: Run the pod with toleration
k delete -f  tolerate-master.yaml
rm -fr tolerate-master.yaml 

cat <<EOF >> tolerate-master.yaml
apiVersion: v1
kind: Pod
metadata:
  name: tolerate-master
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
  tolerations:
  - key: "node-role.kubernetes.io/control-plane"
    operator: "Exists"
    effect: "NoSchedule"
EOF

k apply -f  tolerate-master.yaml
------

#4: Start Worker-1 and Create a NoExecute using the exisiting key value  kubernetes.io/hostname=worker-1

kubectl taint nodes worker-1 kubernetes.io/hostname=worker-1:NoExecute

#3: Run the pod with toleration to deploy in worker-1 node
k delete -f  tolerate-master.yaml
rm -fr tolerate-master.yaml 

cat <<EOF >> tolerate-worker-1.yaml
apiVersion: v1
kind: Pod
metadata:
  name: tolerate-worker-1
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
  tolerations:
  - key: "kubernetes.io/hostname"
    operator: "Equal"
    value: "worker-1"
    effect: "NoExecute"
EOF

k apply -f tolerate-worker-1.yaml


#3: Remove taint of the worker-1 node
kubectl taint nodes worker-1 kubernetes.io/hostname=worker-1:NoExecute-

#4: Check if the Taint was removed
k describe node worker-1

