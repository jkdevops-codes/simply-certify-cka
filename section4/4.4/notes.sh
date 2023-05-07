cat <<EOF >> rgw-svc.yml
apiVersion: v1
kind: Service
metadata:
  name: external-storage-service
spec:
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
EOF
k apply -f rgw-svc.yml

#
cat <<EOF >> rgw-ep.yml
apiVersion: v1
kind: Endpoints
metadata:
 name: external-storage-service
subsets:
- addresses:
   - ip: 192.168.3.21
  ports:
   - port: 8080
- addresses:
   - ip: 192.168.3.22
  ports:
   - port: 8080
- addresses:
   - ip: 192.168.3.23
  ports:
   - port: 8080
EOF
k apply -f rgw-ep.yml

###
cat <<EOF >> rgw-epslice.yml

apiVersion: discovery.k8s.io/v1
kind: EndpointSlice
metadata:
  name: external-storage-epslice
  labels:
    kubernetes.io/service-name: external-storage-service
addressType: IPv4
ports:
  - name: http
    protocol: TCP
    port: 8080
endpoints:
  - addresses:
     - "192.168.3.21"
     - "192.168.3.22"
     - "192.168.3.23"
EOF

k apply -f rgw-epslice.yml



