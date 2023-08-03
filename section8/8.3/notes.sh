k create serviceaccount  sa-reader

#or 

cat <<EOF >> sa-reader.yml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: sa-reader
EOF



k delete -f pod-reader-rolebinding.yml


vim pod-reader-rolebinding.yml

apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pod-reader-rolebinding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: pod-reader
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: user1
- kind: ServiceAccount
  name: sa-reader

 
 k apply -f pod-reader-rolebinding.yml

k run kubectl-test --dry-run=client--image=nginx  -oyaml > kubectl-test.yaml
k apply -f kubectl-test.yaml
k exec -it kubectl-test  -- sh 
#  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
#  chmod +x kubectl
# ./kubectl get po 


k delete -f kubectl-test.yaml
vim kubectl-test.yaml
###############
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: kubectl-test
  name: kubectl-test
spec:
  serviceAccountName: sa-reader
  containers:
  - image: nginx
    name: kubectl-test
#################

cat <<EOF >> sa-secret.yml
apiVersion: v1
kind: Secret
metadata:
 name: sa-secret
 annotations:
  kubernetes.io/service-account.name: "sa-reader"
type: kubernetes.io/service-account-token
EOF

k apply -f sa-with-secret.yml

SA_TOKEN=$(k get secret  sa-secret   -o jsonpath='{.data.token}' | base64 -d)


curl -k -H "Authorization:Bearer ${SA_TOKEN}" https://10.240.0.200:6443/api/v1/namespaces/default/pods



curl -k -H "Authorization:Bearer ${SA_TOKEN}" https://10.240.0.200:6443/api/v1/pods

