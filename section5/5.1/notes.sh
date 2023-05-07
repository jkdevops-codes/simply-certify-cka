k create deployment  mydeploy --image=nginx --replicas=3  --port=80 --namespace=green --dry-run=client -oyaml > mydeployment.yaml
k apply -f mydeployment.yaml

k get po -n green


k get replicaset -n green 

or
k get rs -n green 

