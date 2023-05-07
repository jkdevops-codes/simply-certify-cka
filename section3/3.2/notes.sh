#Kubernetes starts with four initial namespaces:
#default, kube-system, kube-public and kube-node-lease
#default: we can start to create workloads in default without creating addtional namespace
#kube-systme: The namespace for objects created by the Kubernetes system

#Check a pod and its namespace
k get po web-1 -oyaml

#Kubernetes cluster namespaces
#https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/​

#List all namespaces​
k get namespaces
#or
k get ns

#Find pods in default namespace​
k get po --namespace=default
#or
k get po -n default

#Find pods in kube-system namespace​
k get po -n kube-system

#List pods from all the namespaces​
k get po --all-namespaces
#or
k get po -A

#Create a namespace called "green"
k create namespace  green
#or
k create ns green

#List namespaces
k get namespaces

#or
k create namespace  green -oyaml --dry-run=client > green.yaml
k apply -f green.yaml


#Create a nginx pod in the namespace green
k run green-pod --image=nginx -n green
k get po -n green

#delete namespace green 
k delete ns green

