cat <<EOF >> statefulset-demo.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: statefulset-demo
spec:
  serviceName: "nginx"
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: registry.k8s.io/nginx-slim:0.8
        ports:
        - containerPort: 80
          name: web
        volumeMounts:
        - name: test-volume
          mountPath: /usr/share/nginx/html
      volumes:
      - name: test-volume
        hostPath:
          path: /data
          type: DirectoryOrCreate
EOF

k apply -f statefulset-demo.yaml
k get statefulset statefulset-demo

k get po | grep statefulset-demo









