k scale deployment mydeploy -n green --replicas=5
k get po -n green -w 

k patch deployment mydeploy -p '{"spec": {"replicas": 2}}' -n green



k  autoscale deployment mydeploy --min=1 --max=5 --cpu-percent=80  -n green
k get hpa -n green 


