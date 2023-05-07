
#---------------
cat <<EOF > mybash.sh
#! /bin/bash​
while true; 
do 
   echo hello; 
   sleep 5;
done
EOF
k delete po command-demo
#------------


k run command-demo --image=nginx --port=80 --labels="run=command-demo" --command --dry-run=client -oyaml -- sleep 5 > command-demo2.yaml
vim command-demo2.yaml

#modify the command block 

#----------

cat <<EOF > command-demo2.yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: command-demo
  name: command-demo
spec:
  containers:
  - command:
    - "bin/bash"
    - "-c"
    - "while true; do echo hello; sleep 5; done"
    image: nginx
    name: nginx
    ports:
      - containerPort: 80
EOF


k logs -f command-demo
#---------------------
k delete po command-demo

cat <<EOF > command-demo2.yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: command-demo
  name: command-demo
spec:
  containers:
  - image: nginx
    name: nginx
    args:
      - "bin/bash"
      - "-c"
      - "while true; do echo hello; sleep 5; done;"
    ports:
      - containerPort: 80
EOF


k logs -f command-demo




#--------------------
k delete po command-demo

cat <<EOF > command-demo2.yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: command-demo
  name: command-demo
spec:
  containers:
  - args: ["bin/bash", "-c", "while true; do echo hello; sleep 5; done;"]
    image: nginx
    name: nginx
    ports:
      - conainterPort: 80
EOF


k logs -f command-demo


cat <<EOF > command-demo1.yaml
apiVersion: v1
kind: Pod
metadata:
  name: command-demo
  labels:
    purpose: demonstrate-command
spec:
  containers:
  - name: command-demo-container
    image: debian
    command: ["printenv"]
    args: ["HOSTNAME", "KUBERNETES_PORT"]
  restartPolicy: OnFailure
EOF

k apply -f command-demo1.yaml
k logs command-demo




k delete -f command-demo1.yaml
k delete -f command-demo2.yaml