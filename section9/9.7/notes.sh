k run app-1 --image=nginx --labels="app=app-1" --port=80
k run app-2 --image=nginx --labels="app=app-2" --port=80
k run app-3 --image=nginx --labels="app=app-3" --port=80
k run app-4 --image=nginx --labels="app=app-4" --port=80

k expose pod app-1 --port=8080 --target-port=80
k expose pod app-2 --port=8080 --target-port=80
k expose pod app-3 --port=8080 --target-port=80
k expose pod app-4 --port=8080 --target-port=80



#1. Default deny all ingress and all egress traffic  
cat <<EOF >> default-deny-all.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
EOF
k apply -f default-deny-all.yaml


cat <<EOF >> allow-dns-port.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns
spec:
  podSelector:
    matchLabels: {}
  policyTypes:
   - Egress
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: kube-system
      podSelector:
        matchLabels:
          k8s-app: kube-dns
EOF


k apply -f allow-dns-port.yaml



#2. allow app-1 only get inbound (ingress) calls from app-3
cat <<EOF >> app-1-ingress-network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: app-1-ingress-network-policy
spec:
  podSelector:
    matchLabels:
      app: app-1
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: app-3
EOF

k apply -f app-1-ingress-network-policy.yaml

#allow app-3 to egrees to any pods in the default  namespace 
cat <<EOF >> app-3-egress-network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: app-3-egress-network-policy
spec:
  podSelector:
    matchLabels:
      app: app-3
  policyTypes:
    - Egress
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: default
EOF