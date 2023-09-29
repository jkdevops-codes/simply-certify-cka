#Managing Secrets using kubectl
k create secret generic db-user-pass --from-literal=username=admin --from-literal=password='S!B\*d$Dsb=' --dry-run=client -oyaml > db-user-pass.yml
k apply -f db-user-pass.yml

k get secret 
k get secret -n default
k get secret db-user-pass
k get secret -n default

#Create a simple secret using file contents​
rm -fr db-user-pass.yml


echo -n 'admin' > ./username.txt
echo -n 'S!B\*d$zDsb=' > ./password.txt

k create secret generic db-user-pass --from-file=username=./username.txt --from-file=password=./password.txt --dry-run=client -oyaml > db-user-pass.yml
k replace -f db-user-pass.yml --force --grace-period=0


cat <<EOF >> secret-demo.yml
apiVersion: v1
kind: Pod
metadata:
  name: secret-demo
  labels:
    purpose: demonstrate-secret
spec:
  containers:
  - name: secret-demo-container
    image: gcr.io/google-samples/node-hello:1.0
    env:
      - name: USER_NAME
        valueFrom:
          secretKeyRef:
            name: db-user-pass
            key: username 
      - name: PASSWORD
        valueFrom:
          secretKeyRef:
            name: db-user-pass
            key: password 
EOF

#Distribute Credentials Securely Using Secrets

A. Create a SSH Authentication key pair named my-rsa 
B. Create a secret called my-rsa-secret and pass key pair
C. Create a redis pod called redis-pod and mount the key pair files to /etc/foo of the redis container

A. 
ssh-keygen -t rsa -b 4096 -f my-rsa

B. 
k create secret generic my-rsa-secret --from-file=private-key=my-rsa --from-file=public-key=my-rsa.pub
k get secret my-rsa-secret -oyaml
k get secret my-rsa-secret -ojsonpath='{.data.private-key}' | base64 --decode

C.
k run redis-pod --image=redis  --dry-run=client -oyaml > redis-pod.yml
vim redis-pod.yml
#Go to documentation and search for Distribute Credentials Securely Using Secrets
Copy and Paste the volume details

#OR
cat <<EOF >> redis-pod.yml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: redis-pod
  name: redis-pod
spec:
  containers:
  - image: redis
    name: redis-pod
    volumeMounts:
        - name: secret-volume
          mountPath: /etc/foo
  volumes:
    - name: secret-volume
      secret:
        secretName: my-rsa-secret
EOF

k apply -f redis-pod.yml
k exec it redis-pod -- ls /etc/foo
