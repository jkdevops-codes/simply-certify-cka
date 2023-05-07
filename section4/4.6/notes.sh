cat <<EOF >> headless-svc.yml
apiVersion: v1
kind: Service
metadata:
  name: headless-service
  namespace: green
spec:
  clusterIP: None          
  selector:
    app: myweb
  ports:
    - name: web-port
      protocol: TCP
      port: 80
      targetPort: 80
EOF

k apply -f headless-svc.yml