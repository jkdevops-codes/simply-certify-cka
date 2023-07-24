Authentication, Authorization

#refer the document 
https://kubernetes.io/docs/concepts/security/controlling-access/


openssl genrsa -out david.key 2048
openssl req -new -key david.key -out david.csr -subj "/CN=david/O=devops-team"


cat <<EOF | tee david-csr.yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: david-csr
spec:
  request: $(cat david.csr | base64 -w 0)
  usages:
  - client auth
EOF


k apply -f david-csr.yaml

k get csr

kubectl certificate approve david-csr

kubectl get csr

kubectl get csr david-csr -o jsonpath='{.status.certificate}' | base64 -d > david.crt

kubectl config set-credentials david --client-certificate=david.crt --client-key=david.key
kubectl config set-context david-context --cluster= --namespace=lfs158 --user=bob

kubectl config set-cluster kubernetes --certificate-authority=ca.crt --embed-certs=true --server=${API_SERVER} --kubeconfig=kubelet.conf
kubectl config set-credentials david --client-certificate=david.crt --client-key=david.key --embed-certs=true --kubeconfig=david.conf
kubectl config set-context david-context --cluster=kubernetes --user=david --kubeconfig=david.conf




In order to be authorized by the Node authorizer, kubelets must use a credential that identifies them as being in the system:nodes group

system:masters group which is hardcoded into the Kubernetes API server source code as having unrestricted rights to the Kubernetes API server.

