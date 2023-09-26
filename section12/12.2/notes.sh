k create ns netpolicy

k run app-1 --image=nginx --labels="app=app-1" --port=80 -n netpolicy
k run app-2 --image=nginx --labels="app=app-2" --port=80 -n netpolicy
k run app-3 --image=nginx --labels="app=app-3" --port=80 -n netpolicy
k run app-4 --image=nginx --labels="app=app-4" --port=80 -n netpolicy

k expose pod app-1 --port=8080 --target-port=80 -n netpolicy
k expose pod app-2 --port=8080 --target-port=80 -n netpolicy
k expose pod app-3 --port=8080 --target-port=80 -n netpolicy
k expose pod app-4 --port=8080 --target-port=80 -n netpolicy


k run netchecker --image=nginx --labels="app=netchecker" --port=80 -n netpolicy
k exec -it netchecker -n netpolicy -- apt update
k exec -it netchecker -n netpolicy -- apt install dnsutils


#1. Default deny all ingress and all egress traffic  
cat <<EOF >> default-deny-all.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: netpolicy
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
EOF
k apply -f default-deny-all.yaml


cat <<EOF >> allow-dns.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns
  namespace: netpolicy
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
k apply -f allow-dns.yaml

#OR

cat <<EOF >> allow-dns-port.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns-port
  namespace: netpolicy
spec:
  podSelector: {}
  policyTypes:
  - Egress
  - Ingress
  egress:
  - ports:
    - port: 53
      protocol: TCP
    - port: 53
      protocol: UDP
EOF
k apply -f allow-dns-port.yaml


#Clean
k delete po app-1 --force --grace-period=0  -n netpolicy
k delete po app-2 --force --grace-period=0 -n netpolicy
k delete po app-3 --force --grace-period=0 -n netpolicy
k delete po app-4 --force --grace-period=0 -n netpolicy

k delete svc app-1 --force --grace-period=0 -n netpolicy
k delete svc app-2 --force --grace-period=0 -n netpolicy
k delete svc app-3 --force --grace-period=0 -n netpolicy
k delete svc app-4 --force --grace-period=0 -n netpolicy

k delete -f default-deny-all.yaml
k delete -f allow-dns-port.yaml

rm -fr default-deny-all.yaml
rm -fr allow-dns-port.yaml