cat <<EOF > liveness-test.yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    test: liveness
  name: liveness-http
spec:
  containers:
  - name: liveness
    image: registry.k8s.io/liveness
    args:
    - /server
    livenessProbe:
      httpGet:
        path: /healthz
        port: 8080
        httpHeaders:
        - name: Custom-Header
          value: Awesome
      initialDelaySeconds: 3
      periodSeconds: 3
EOF


#-----------
cat <<EOF > startup-test.yaml
apiVersion: v1
kind: Pod
metadata:
  name: startup-probe
spec:
  containers:
  - name: startup-probe-demo
    image: busybox:latest
    args:
    - /bin/sh
    - -c
    - sleep 3600
    startupProbe:
      exec:
        command:
        - cat
        - /etc/hostname
      periodSeconds: 10
      failureThreshold: 10
EOF

