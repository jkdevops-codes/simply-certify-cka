# Kubernetes Ingress is an API entity that enables external access to your Kubernetes services. 
#It acts as a routing table, allowing you to control and manage access to services within a Kubernetes cluster from outside networks.

#### 1. Setup nginx ingress controller ####
    #Refer: https://github.com/nginxinc/kubernetes-ingress.git

git clone https://github.com/nginxinc/kubernetes-ingress.git 
cd kubernetes-ingress/deployments
kubectl apply -f common/ns-and-sa.yaml #Creates namespace and service account for the ingress controller
kubectl apply -f rbac/rbac.yaml #In the Kubernetes cluster create rbac with cluster role resource and cluster role binding resource for service account.
kubectl apply -f common/nginx-config.yaml #NGINX configuration 
kubectl apply -f common/ingress-class.yaml # It creates an IngressClass resource.

## Apply custom resource definitions (CRDS) for VirtualServer, VirtualServerRoute, TransportServer and Policy. 
kubectl apply -f common/crds/k8s.nginx.org_virtualservers.yaml
kubectl apply -f common/crds/k8s.nginx.org_virtualserverroutes.yaml
kubectl apply -f common/crds/k8s.nginx.org_transportservers.yaml
kubectl apply -f common/crds/k8s.nginx.org_policies.yaml

kubectl apply -f common/crds/k8s.nginx.org_globalconfigurations.yaml #To utilize the TCP and UDP load balancing aspects of the Ingress Controller,

#When you run the Ingress Controller by using a DaemonSet, 
#Kubernetes will create an Ingress controller pod on every node of the cluster.
kubectl apply -f daemon-set/nginx-ingress.yaml
kubectl create -f service/nodeport.yaml



#### 2. Check if Ingress Controller installed properly  #### 
#Check if everything running fine
k get all -n nginx-ingress 




#### 3. Create a deployment and expose it  #### 
#Create a demo deployment and expose as service called demo
kubectl create deployment demo --image=httpd --port=80
kubectl expose deployment demo



#### 4. Create an Ingress Object  #### 
kubectl create ingress demo-localhost --class=nginx --rule="demo.localdev.me/*=demo:80"
#or 
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: demo-localhost
  namespace: default
spec:
  ingressClassName: nginx
  rules:
  - host: demo.localdev.me
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: demo
            port:
              number: 80
EOF


#If we are checking the ingress from master node, add all worker nodes to /etc/hosts for the domain demo.localdev.me for testing
sudo vim /etc/hosts
10.20.0.13 demo.localdev.me

#Test the URL
curl http://demo.localdev.me
