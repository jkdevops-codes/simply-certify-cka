# Create a namespace named cpu-example and create multiple pods given in the source code 
k create ns cpu-example

cat <<EOF >> top-test.yaml
apiVersion: v1
kind: Pod
metadata:
  name: cpu-demo
  namespace: cpu-example
spec:
  containers:
  - name: cpu-demo-ctr
    image: vish/stress
    resources:
      limits:
        cpu: "1"
      requests:
        cpu: "0.5"
    args:
    - -cpus
    - "2"
---
apiVersion: v1
kind: Pod
metadata:
  name: cpu-demo-2
  namespace: cpu-example
spec:
  containers:
  - name: cpu-demo-ctr
    image: vish/stress
    resources:
      limits:
        cpu: "1"
      requests:
        cpu: "0.5"
    args:
    - -cpus
    - "2"
---
apiVersion: v1
kind: Pod
metadata:
  name: busy-pod-1
  namespace: cpu-example
spec:
  containers:
  - name: busy-container-1
    image: busybox
    command: ["/bin/sh", "-c"]
    args:
    - "while true; do echo 'Hello from Pod 1'; sleep 0.1; done"
    resources:
      limits:
        cpu: "200m"
        memory: "256Mi"
EOF

k apply -f top-test.yaml
