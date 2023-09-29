Authentication, Authorization

#refer the document 
https://kubernetes.io/docs/concepts/security/controlling-access/

#Create user key and CSR
openssl genrsa -out user1.key 2048
openssl req  -new -key user1.key -out user1.csr -subj="/CN=user1/O=devops-team"



#Create CertificateSigningRequest object
cat <<EOF | tee user1-csr.yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: user1-csr
spec:
  request: $(cat user1.csr | base64 -w 0)
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF
k apply -f user1-csr.yaml


#Approve CSR
k get csr
k get csr user1-csr -oyaml
k certificate approve user1-csr
k get csr user1-csr -oyaml

#Obtain generated certificate 
k get csr user1-csr -o jsonpath='{.status.certificate}' | base64 -d > user1.crt


#Add the user context to current config
k config set-credentials user1 --client-certificate=user1.crt --client-key=user1.key --embed-certs=true
k config set-context user1-context --cluster=kubernetes --namespace=default --user=user1



#Check the config file 
k config viw

#Try to create a pod using new user context
k get pods --context=user1-context 

#Check the permission user1 having
k auth can-i create pod