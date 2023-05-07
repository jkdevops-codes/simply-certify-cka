#Run a Pod
kubectl run mypod  --image=nginx --port=80
kubectl get pods  mypod -o yaml

cat <<EOF >> mypod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
EOF

kubectl create -f  mypod.yaml

# Generate Pod YAML Definition
kubectl run mypod --image=nginx --port=80  --dry-run=client -oyaml
alias k=kubectl
k get po -owide
k describe po mypod
k logs -f mypod
k get po --show-labels

#Question
#Create following pods and list all pods sorted by container image names. ​
#web-1, httpd:alpine
#mywebserver, httpd:bullseye
#schema-converter, nginx
#transaction-manager, nginx:1.23.3
#wordpress, php:apache

#Get a shell to running pod transaction-manager with stdin and tty mode and check if the web server is working.​

k run web-1 --image=httpd:alpine
k run mywebserver --image=httpd:bullseye
k run schema-converter --image=nginx
k run transaction-manager --image=nginx:1.23.3
k run wordpress --image=php:apache

#watch while pods creating 
k get po --watch
#or
k get po -w

#Get shell to a running pod 
k exec -it transaction-manager -- sh

#sort the running pods by image name
#refer: https://kubernetes.io/docs/reference/kubectl/cheatsheet/

k get po web-1 -ojson

k get pods --sort-by='.spec.containers[0].image'
