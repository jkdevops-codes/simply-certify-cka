#Make a namespace in Kubernetes called 'cpu-example' and create pods as described in the code found at https://github.com/jkdevops-codes/simply-certify-cka/blob/master/section13/metrics.sh.

#After finishing this, double-check that the Metric Server is installed. If it's not installed yet, follow the setup instructions in section 3.9 at https://github.com/jkdevops-codes/simply-certify-cka/blob/master/section3/3.9/metrics-server.yaml.

#Look at how much memory the pods are using in the 'cpu-example' area, and organize the results based on memory usage.

#Take a look at the logs from the busybox container inside the pod called busy-pod-1, and save what you see into a file named busylogs.txt

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
  - name: nginx
    image: nginx
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


