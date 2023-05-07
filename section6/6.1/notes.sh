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
cat envar-demo-cm.yml

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





cat <<EOF >> envar-demo-cm.yml
apiVersion: v1
kind: ConfigMap
metadata:
  name: envar-demo-cm
data:
  CM_DEMO_GREETING: "Hello World"
  CM_DEMO_FAREWELL: "Sweet sorrow"
EOF

k create -f envar-demo-cm.yml

#Check if configmap created 
k get configmap envar-demo-cm 
#or
k get cm 


k create  -f envar-demo.yml




#Method2: Create or generate ConfigMap using kubectl tool
k delete cm envar-demo-cm 
k delete po envar-demo
#or
k delete -f envar-demo-cm.yml
k delete -f envar-demo.yml

k rm -fr envar-demo-cm.yml

#Generate configmap yaml definition
k create configmap envar-demo-cm --from-literal=DEMO_GREETING="hello from kubernetes" --from-literal=DEMO_FAREWELL="Such a sweet moment"  --dry-run=client -oyaml > envar-demo-cm.yml
k create -f envar-demo-cm.yml
k create -f envar-demo.yml



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

k create -f envar-demo.yml

k exec -it envar-demo -- printenv | grep DEMO_

#Delete and recreate configmap using kubectl command line
k delete  -f envar-demo-cm.yml
k create configmap envar-demo-cm --from-literal=DEMO_GREETING=hello from kubernetes --from-literal=DEMO_FAREWELL=Such a sweet moment  --labels=purpose=demonstrate-envars


#-------------------------------------Passing all key/values of a configmap to a file ----------------------------
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
    envFrom:
    - configMapRef:
           name: envar-demo-cm
EOF

#-------------------------------------Passing a file to a pod through a configmap ----------------------------

k delete -f envar-demo.yml
k delete -f envar-demo-cm.yml



cat <<EOF >> envar-demo-cm.yml
apiVersion: v1
kind: ConfigMap
metadata:
  name: envar-demo-cm
data:
  redis-config: |
    port 6380
    timeout 0
    loglevel verbose
    logfile stdout
    maxmemory 2mb
    maxmemory-policy allkeys-lru 
EOF
k create -f envar-demo-cm.yml


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

k create -f envar-demo.yml
 

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
      name: my-config-map
      items:
      - key: "redis-config"
        path: "redis-config"
EOF

k create -f envar-demo.yml