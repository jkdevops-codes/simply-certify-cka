cat <<EOF > emptydir-demo.yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-pd
spec:
  containers:
  - image: nginx
    name: test-container
    volumeMounts:
    - mountPath: /cache
      name: cache-volume
  volumes:
  - name: cache-volume
    emptyDir: {}
EOF

#Simple Pod
cat <<EOF > emptydir-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: emptydir-pod
  name: emptydir-pod
spec:
  containers:
  - image: nginx
    name: nginx
    ports:
    - containerPort: 80    
EOF

k exec -it emptydir-pod  -- curl http://localhost
k logs emptydir-pod 
#Check the document root /usr/share/nginx/html/ and there is file index.html


#Multi Container Pod

k delete po emptydir-pod --force  #Delete the pod before continue
cat <<EOF > emptydir-pod.yaml  #Please delete the existing pod before continue using aboove command
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: emptydir-pod
  name: emptydir-pod
spec:
  containers:
  - image: nginx
    name: nginx
    ports:
    - containerPort: 80    
  - image: alpine
    name: alpine
    command: ["sh", "-c", "echo I am busybox conatiner;sleep 3600;"]
EOF

#Pods with Empty Dir
cat <<EOF > emptydir-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: emptydir-pod
  name: emptydir-pod
spec:
  containers:
  - image: nginx
    name: nginx
    volumeMounts:
    - mountPath: /usr/share/nginx/html/
      name: my-volume
    ports:
    - containerPort: 80
  - image: alpine
    name: alpine
    volumeMounts:
    - mountPath: /work-dir/
      name: my-volume
    command: ["sh", "-c", "echo hello world > /work-dir/index.html ;sleep 3600;"]
  volumes:
  - name: my-volume
    emptyDir: {}
EOF

k exec -it emptydir-pod -c nginx -- curl http://localhost



k delete -f emptydir-pod.yaml