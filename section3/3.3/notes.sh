#Create a pod definition that includes CPU/Memory Limits​
kubectl run apache-php --image=nginx  --labels="app=myweb" --dry-run=client -oyaml  > simple-pod.yaml
#Add resource to pod file locally without connecting to API Server​
kubectl set resources -f simple-pod.yaml --local --requests=cpu=100m,memory=256Mi --limits=cpu=200m,memory=512Mi -o yaml > resource-pod.yaml
#Check the generated file 
cat resource-pod.yaml
#Apply manifest
k apply -f resource-pod.yaml
#Check running manifest
k get po apache-php -oyaml


#Create pods definition only with resources limit​
kubectl set resources -f simple-pod.yaml --local --limits=cpu=200m,memory=512Mi -o yaml > resource-pod.yaml
k delete po apache-php
k apply -f resource-pod.yaml
k get po apache-php -oyaml
#If only resources limit is applied without request, ​Request will take the limit resources values​



#Create pods definition only with resources request
kubectl set resources -f simple-pod.yaml --local --requests=cpu=100m,memory=256Mi -o yaml > resource-pod.yaml
k delete po apache-php
k apply -f resource-pod.yaml
k get po apache-php -oyaml
#If only resources requests is applied without limit, Only request values will be applied. 
#If resources applied through namespace level, then pod will inherit namespace limit values


#Limit Range
cat <<EOF > limitrange.yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: my-resource-contraint
  namespace: default
spec:
  limits:
  - default: # this section defines default limits
      cpu: "300m"
      memory: "600Mi"
    defaultRequest: # this section defines default requests
      cpu: "100m"
      memory: "300Mi"
    type: Container
EOF




