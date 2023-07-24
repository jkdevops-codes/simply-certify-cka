#### Node Affinity 
#delete: https://www.devopsschool.com/blog/understanding-node-selector-and-node-affinity-in-kubernetes/

# A pod needs to be deployed on specialized hardware-supported nodes, such as an SSD drive or a GPU.
# A pod needs to be deployed always with a colocated specific pod.
# A pod with high resource requirements might need to be deployed to specific nodes.

#Add labels to nodes
k label nodes worker-1 nodetype=highcpu
k label nodes worker-1 disktype=ssd

k label nodes worker-2 nodetype=highcpu
k label nodes worker-2 disktype=pd

k label nodes worker-3 nodetype=lowcpu
k label nodes worker-3 disktype=ssd


#Create Node Affinity  - Hard Rule
cat <<EOF >> node-affinity-example.yaml
apiVersion: v1
kind: Pod
metadata:
  name: node-affinity-example
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: nodetype
            operator: In
            values:
            - lowcpu
          - key: disktype
            operator: In
            values:
            - ssd
  containers:
  - name: with-node-affinity
    image: registry.k8s.io/pause:2.0
EOF

k apply -f node-affinity-example.yaml 


#Create Node Affinity - Soft Rule
k delete -f node-affinity-example.yaml
rm -fr node-affinity-example.yaml

cat <<EOF >> node-affinity-example.yaml
apiVersion: v1
kind: Pod
metadata:
  name: node-affinity-example
spec:
  affinity:
    nodeAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 1
        preference:
          matchExpressions:
          - key: server
            operator: In
            values:
            - data
  containers:
  - name: with-node-affinity
    image: registry.k8s.io/pause:2.0
EOF
k apply -f node-affinity-example.yaml

#Create Node Affinity - Soft Rule
k delete -f node-affinity-example.yaml
k label nodes worker-3 server=data
k apply -f node-affinity-example.yaml




#Create Node Affinity - Soft Rule - Weight Score
k delete -f node-affinity-example.yaml
rm -fr node-affinity-example.yaml

cat <<EOF >> node-affinity-example.yaml
apiVersion: v1
kind: Pod
metadata:
  name: node-affinity-example
spec:
  affinity:
    nodeAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 50
        preference:
          matchExpressions:
          - key: server
            operator: In
            values:
            - data
      - weight: 30
        preference:
          matchExpressions:
          - key: nodetype
            operator: In
            values:
            - highcpu
      - weight: 40
        preference:
          matchExpressions:
          - key: disktype
            operator: In
            values:
            - pd
  containers:
  - name: with-node-affinity
    image: registry.k8s.io/pause:2.0
EOF
k apply -f node-affinity-example.yaml


k explain pod.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoreDuringExecution.nodeSelectorTerms.matchExpressions.operator

#worker-3: nodetype=lowcpu, disktype=ssd, server=data
#worker-2: nodetype=highcpu, disktype=pd
#worker-1: nodetype=highcpu, disktype=ssd


