#1. Create Namespaces:
#   Create two namespaces named green and yellow.
k create ns green
k create ns yellow

#2. Create Redis Server Pod:
#   Create a Pod named redis-server in the green namespace using the image docker.io/redis:6.0.5. Add labels app=redis,type=cache  and expose port number 6379.

#3. Create Web Server Pods:
#   Create a Pod named web-server-1 in the yellow namespace using the image nginx. Add labels app=nginx and type=webserver.
#   Create a Pod named web-server-2 in the yellow namespace using the image nginx. Add labels app=nginx and type=webserver.
#   Create a Pod named jetty-server in the yellow namespace using the image jetty:9.4.53-jre8-alpine. Add labels app=jetty and type=webserver.

k run redis-server --image=docker.io/redis:6.0.5 --labels="app=redis,type=cache" -n green --port=6379
k run web-server-1 --image=nginx --labels="app=nginx,type=webserver" -n yellow --port=80
k run web-server-2 --image=nginx --labels="app=nginx,type=webserver" -n yellow --port=80
k run jetty-server --image=jetty:9.4.53-jre8-alpine --labels="app=jetty,type=webserver" -n yellow --port=8080


#4. Network Policies:
#   Deny all inbound and outbound traffic for pods in the green namespace.
cat <<EOF > deny-all.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-green
  namespace: green
spec:
  podSelector: {}
  policyTypes:
    - Ingress
    - Egress
EOF

k apply -f deny-all.yaml


#   Allow redis-server outbound call to anypods in the namespace yellow 
cat <<EOF > allow-redis-outbound.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-redis-outbound
  namespace: green
spec:
  podSelector:
    matchLabels:
      app: redis
  policyTypes:
    - Egress
  egress:
    - to:
      - namespaceSelector:
          matchLabels:
            kubernetes.io/metadata.name: yellow
EOF

k apply -f allow-redis-outbound.yaml

#   Allow all pods in the yellow namespace to connect to port number 6379 in the green namespace.

cat <<EOF > allow-yellow-to-green.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-yellow-to-green
  namespace: green
spec:
  podSelector: {}
  ingress:
    - from:
      - namespaceSelector:
          matchLabels:
            name: yellow
      ports:
      - protocol: TCP
        port: 6379
EOF

k apply -f allow-yellow-to-green.yaml
