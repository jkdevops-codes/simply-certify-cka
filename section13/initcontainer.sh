#1.Create a YAML pod definition file named 'busy-pod.yaml' with a pod named 'busy-pod.' Use the 'busybox' image, add a Linux command 'sleep 1200' to the pod, and run it using the YAML definition.
k run  busy-pod --image=busybox  --command  --dry-run=client -oyaml -- sleep 1200 > busy-pod.yaml
k apply -f busy-pod.yaml


#2. Modify the YAML file and re-run it to attach a volume named 'my-volume' and mount it at the path '/data' for the 'busy-pod' pod.
vim busy-pod.yaml

#Search for emptyDir in kubernetes document and go to https://kubernetes.io/fr/docs/concepts/storage/volumes/

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: busy-pod
  name: busy-pod
spec:
  volumes:
  - name: my-volume
    emptyDir: {}
  containers:
  - command:
    - sleep
    - "1200"
    image: busybox
    name: busy-pod
    volumeMounts:
    - mountPath: /data
      name: my-volume
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}


k delete -f busy-pod.yaml
k apply -f busy-pod.yaml

#3. Make further modifications to the YAML file and re-run it to add an initContainer with the 'nginx' image to the 'busy-pod.' Mount the 'my-volume' at '/data' and create a file named 'action.txt' with the content 'start.'

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: busy-pod
  name: busy-pod
spec:
  volumes:
  - name: my-volume
    emptyDir: {}
  initContainers:
    - name: init-container
      image: nginx
      command: ["sh", "-c", "echo 'start' > /data/action.txt"]
      volumeMounts:
        - name: my-volume
          mountPath: /data
  containers:
  - command:
    - sleep
    - "1200"
    image: busybox
    name: busy-pod
    volumeMounts:
    - mountPath: /data
      name: my-volume
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}

k delete po busy-pod
k apply -f busy-pod.yaml

#4. Once again, modify and run the YAML file to ensure that the 'busy-pod' terminates if '/data/action.txt' exists and contains the content 'stop.'

apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: busy-pod
  name: busy-pod
spec:
  volumes:
  - name: my-volume
    emptyDir: {}
  initContainers:
    - name: init-container
      image: nginx
      command: ["sh", "-c", "echo 'stop' > /data/action.txt"]
      volumeMounts:
        - name: my-volume
          mountPath: /data
  containers:
  - command: ["sh", "-c", "if [ -f /data/action.txt ]; then if  grep -q 'stop' '/data/action.txt'; then exit 0; fi; fi; sleep 1200;"]
    image: busybox
    name: busy-pod
    volumeMounts:
    - mountPath: /data
      name: my-volume
    resources: {}
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}


k delete po busy-pod
k apply -f busy-pod.yaml