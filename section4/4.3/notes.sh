cat <<EOF >> redis-svc.yml
apiVersion: v1
kind: Service
metadata:
  name: redis-svc
spec:
  ports:
    - protocol: TCP
      port: 80
      targetPort: 9376
EOF

k apply -f redis-svc.yml

cat <<EOF >> redis-ep.yml
apiVersion: v1
kind: Endpoints
metadata:
  name: redis-svc
subsets:
  - addresses:
      - ip: 192.0.2.42
    ports:
      - port: 9376
EOF

k apply -f redis-ep.yml