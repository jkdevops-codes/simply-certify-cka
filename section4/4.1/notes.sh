#Generate a pod called pod-1 in the namespace green with label app=myweb​
k run pod-a --image=nginx --namespace=green --port=80 --labels=app=myweb -oyaml --dry-run=client > pod-a.yaml
k apply -f  pod-a.yaml

k run pod-b --image=nginx --namespace=green --port=80 --labels=app=myweb -oyaml --dry-run=client > pod-b.yaml
k apply -f  pod-b.yaml

#Generate the Service Manifest for the pod pod-a​
k expose pod pod-a --name=mysvc --namespace=green --port=8080 --target-port=80 --dry-run=client -oyaml > mysvc.yaml
#create the service 
k apply -f mysvc.yaml

#List the services from  green namespace​
k get svc -n green
k get svc mysvc -n green
k get svc mysvc -n green -oyaml

#Check the generated endpoint with the Service ​
k get endpoints -n green
k get ep -n green
k get ep mysvc -n green -oyaml

#    apiVersion: v1
#    kind: Endpoints
#    metadata:
#      labels:
#        app: myweb
#      name: mysvc
#      namespace: green
#    subsets:
#    - addresses:
#      - ip: 192.168.133.193
#        nodeName: worker-2
#        targetRef:
#          kind: Pod
#          name: pod-b
#          namespace: green
#      - ip: 192.168.226.65
#        nodeName: worker-1
#        targetRef:
#          kind: Pod
#          name: pod-a
#          namespace: green
#      ports:
#      - port: 80
#        protocol: TCP




#Other kubectl useful commands
k get svc mysvc -n green --show-labels
k delete svc mysvc -n green

#Port-Forward
k port-forward svc/mysvc -n green 8080:80
k port-forward po pod-a -n green 8080:80


#Send Request to pod-a and pod-b through mysvc service​
k run --rm -it test-pod --image=ubuntu -n green -- sh
#install curl and send a GET request to pods through Service
#curl http://mysvc.green.svc.cluster.local


