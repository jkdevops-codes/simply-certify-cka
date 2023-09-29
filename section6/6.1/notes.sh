#-------------------------------------Pods environement variable  ----------------------------
cat <<EOF >> envar-demo.yml
apiVersion: v1
kind: Pod
metadata:
  name: envar-demo
  labels:
    purpose: demonstrate-envars
spec:
  containers:
  - name: envar-demo-container
    image: gcr.io/google-samples/node-hello:1.0
    env:
    - name: DEMO_GREETING
      value: "Hello World"
    - name: DEMO_FAREWELL
      value: "Sweet sorrow"
EOF

k create -f envar-demo.yml
k exec -it envar-demo -- printenv | grep DEMO

k delete -f envar-demo.yml

#-------------------------------------De-couple pods environement variable to seperate configmap file  ----------------------------
k create configmap envar-demo-cm --from-literal=CM_DEMO_GREETING="Hello World" --from-literal=CM_DEMO_FAREWELL="Sweet moment"  --dry-run=client -oyaml > envar-demo-cm.yml
vim envar-demo-cm.yml
k apply -f envar-demo-cm.yml

#Check if configmap created 
k get configmap  
#or
k get cm 
#or
k get configmap envar-demo-cm 
#or
k get configmap envar-demo-cm  -n default


rm -fr envar-demo.yml
cat <<EOF >> envar-demo.yml
apiVersion: v1
kind: Pod
metadata:
  name: envar-demo
  labels:
    purpose: demonstrate-envars
spec:
  containers:
  - name: envar-demo-container
    image: gcr.io/google-samples/node-hello:1.0
    env:
      - name: DEMO_GREETING
        valueFrom:
          configMapKeyRef:
            name: envar-demo-cm 
            key: CM_DEMO_GREETING 
      - name: DEMO_FAREWELL
        valueFrom:
          configMapKeyRef:
            name: envar-demo-cm 
            key: CM_DEMO_FAREWELL 
EOF
k replace  -f envar-demo.yml --force --grace-period=0

##-------------------------------------Passing all key/values of a configmap to a file ----------------------------
rm -fr  envar-demo.yml

cat <<EOF >> envar-demo.yml
apiVersion: v1
kind: Pod
metadata:
  name: envar-demo
  labels:
    purpose: demonstrate-envars
spec:
  containers:
  - name: envar-demo-container
    image: gcr.io/google-samples/node-hello:1.0
    envFrom:
    - configMapRef:
           name: envar-demo-cm
EOF

k replace -f envar-demo.yml --force --grace-period=0

#-------------------------------------Passing a file to a pod through a configmap ----------------------------

rm -fr envar-demo-cm.yml

cat <<EOF >> redis-config
port 6380
timeout 0
loglevel verbose
logfile stdout
maxmemory 2mb
maxmemory-policy allkeys-lru 
EOF

k create configmap envar-demo-cm --from-file=redis-config=redis-config --from-literal=CM_DEMO_FAREWELL="Sweet moment"  --dry-run=client -oyaml > envar-demo-cm.yml

k replace -f envar-demo-cm.yml --force --grace-period=0

#Alternate way
rm -fr envar-demo-cm.yml
cat <<EOF >> envar-demo-cm.yml
apiVersion: v1
kind: ConfigMap
metadata:
  name: envar-demo-cm
data:
  redis-config: |
    port=6380
    timeout=0
    loglevel=verbose
    logfile=stdout
    maxmemory=2mb
    maxmemory-policy=allkeys-lru 
EOF

k replace -f envar-demo-cm.yml --force --grace-period=0
k replace -f envar-demo.yml --force --grace-period=0

#-------------------------------------Passing a file to a pod through a configmap using volume ----------------------------
k delete -f envar-demo.yml
cat <<EOF >> envar-demo.yml
apiVersion: v1
kind: Pod
metadata:
  name: envar-demo
  labels:
    purpose: demonstrate-envars
spec:
  containers:
  - name: envar-demo-container
    image: gcr.io/google-samples/node-hello:1.0
    volumeMounts:
    - mountPath: /redis-master
      name: config
  volumes:
  - name: config
    configMap:
      name: envar-demo-cm
      items:
      - key: "redis-config"
        path: "redis-config"
EOF

k create -f envar-demo.yml

#-------------------------------------Question ----------------------------
k create configmap color-cm --from-literal=color1=red --from-literal=color2=blue -n green
k run color-pod --image=nginx -n green --dry-run=client -oyaml > color-pod.yaml
#Modify the file using documentation with keyword CofngiMap