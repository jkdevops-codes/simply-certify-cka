#1. allow app-1 only get inbound (ingress) calls from app-3
cat <<EOF >> app-1-ingress-network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: app-1-ingress-network-policy
  namespace: netpolicy
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

#2. allow app-3 to egrees to any pods in the default  namespace 
cat <<EOF >> app-3-egress-network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: app-3-egress-network-policy
  namespace: netpolicy
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
              kubernetes.io/metadata.name: netpolicy
EOF

k apply -f app-3-egress-network-policy.yaml


#Clean
k delete -f  app-1-ingress-network-policy.yaml
k delete -f app-3-egress-network-policy.yaml
rm -fr  app-1-ingress-network-policy.yaml
rm -fr app-3-egress-network-policy.yaml
