#Kubernetes Metrics API should have been installed to collect resource metrics from pods and nodes​

#Check if metric server installed
k get po -n kube-system | grep metrics-server


#Install Metrics API 
kubectl apply -f metrics-server.yaml


# kubectl top is command to provide the snapshot of the resource utilization metrics like CPU, memory, and storage on each running nodes and pods

k top pod 
k top pod  -n green
k top pod  --sort-by='cpu' 
k top pod  --sort-by='cpu' --containers

k top node
k top node --sort-by='memory'
