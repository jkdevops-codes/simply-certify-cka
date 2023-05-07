cat <<EOF > init-demo.yaml
apiVersion: v1
kind: Pod
metadata:
  name: init-demo
  labels:
    app: init-demo
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
    volumeMounts:
    - name: workdir
      mountPath: /usr/share/nginx/html
  # These containers are run during pod initialization
  initContainers:
  - name: install
    image: busybox:1.28
    command:
    - wget
    - "-O"
    - "/work-dir/index.html"
    - http://info.cern.ch
    volumeMounts:
    - name: workdir
      mountPath: "/work-dir"
  dnsPolicy: Default
  volumes:
  - name: workdir
    emptyDir: {}
EOF

#Lets expose the pod as NodePod Type service and check through WorkerNode IP
k expose po init-demo --port=80 --type=NodePort --name=init-demo-svc

Create a Pod that has one application Container (nginx webserver ) and one Init Container(busybox).
Override the defaul home page () of nginx server  



wget -O /work-dir/index.html http://info.cern.ch
Notice that the init container writes the index.html file in the root directory of the nginx server.

Create the Pod: