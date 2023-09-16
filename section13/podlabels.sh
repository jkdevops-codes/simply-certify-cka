#You are tasked with setting up access controls within a Kubernetes cluster to manage permissions for a specific use case
#1. Create following pods with labels
#2. List all the pods with labels
#3. Find only pods with type=web
#4. Expose all the pods with port 80
#5. List the services with their labels:
#6. Find the pods running in worker-1
#7. Find the Node which is set to NoExecute
#8. List pods and sort them by their container image name
#9. Add a label module=banking to a running pod web-1
#10. Upgrade the transaction-manager pods container image to 1.24.0​

#1
k run web-1 --image=httpd:alpine --labels="app=web-1,type=web" --port=80
k run mywebserver --image=httpd:bullseye --labels="app=mywebserver,type=web"  --port=80
k run schema-converter --image=nginx --labels="app=mywebserver,type=web" --port=80
k run transaction-manager --image=nginx:1.23.3 --labels="app=transaction-manager,type=general" --port=80
k run wordpress --image=php:apache --labels="app=wordpress,type=web" --port=80


#2. List all the pods with labels
k get pods --show-labels

#3. Find only pods with type=web
k get pods -l type=web

#4. Expose all the pods with port 80 
k expose pod web-1 --port=80
k expose pod mywebserver --port=80
k expose pod schema-converter --port=80
k expose pod transaction-manager --port=80
k expose pod wordpress --port=80


#5. List the services with their labels:
k get svc --show-labels

#6. Find the pods running in worker-1
k get pods -o wide | grep worker-1
#or
k get pods -o wide --field-selector spec.nodeName=worker-1


#7. Find the Node which is set to NoExecute
k describe node | grep NoExecute


#8. List pods and sort them by their container image name
k get pods --sort-by=.spec.containers[0].image

#9. Add a label module=banking to a running pod web-1
k label pod web-1 module=banking

#10. Upgrade the transaction-manager pods container image to 1.24.0 
k set image pod/transaction-manager transaction-manager=nginx:1.24.0 


#Delete all the pods 
k delete po  web-1
k delete po  mywebserver
k delete po  schema-converter
k delete po  transaction-manager
k delete po  wordpress
