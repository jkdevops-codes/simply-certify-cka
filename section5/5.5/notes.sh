#Exercise

#Create a deployment
k create deployment kubernetes-bootcamp --image=gcr.io/google-samples/kubernetes-bootcamp:v1

#Scale the deployment replicas to 5
k scale deployments/kubernetes-bootcamp --replicas=5

#Check the UpdateStrategy (Default RollingUpdate)
k get deploy kubernetes-bootcamp -oyaml

#Command to change the stragey if not RollingUpdate
k patch deployment kubernetes-bootcamp  -p '{"spec":{"strategy":{"type":"RollingUpdate"}}}' 

#Set the RollingUpdate attributes maxSurge and maxUnavailable
k patch deployment kubernetes-bootcamp  -p '{"spec":{"strategy":{"rollingUpdate":{"maxSurge": "60%"}}}}' 
k patch deployment kubernetes-bootcamp  -p '{"spec":{"strategy":{"rollingUpdate":{"maxUnavailable": "60%"}}}}' 

 
#Update the deployment image 
k set image deployments/kubernetes-bootcamp kubernetes-bootcamp=jocatalin/kubernetes-bootcamp:v2

#Verify the deployment image  update
k rollout status deployments/kubernetes-bootcamp

#Check rollout revision  history
k rollout history deployments/kubernetes-bootcamp

#Update with record option to check the change cause
k set image deployments/kubernetes-bootcamp kubernetes-bootcamp=jocatalin/kubernetes-bootcamp:v1 --record


#Check rollout version history
k rollout history deployments/kubernetes-bootcamp

#Roll back with revision number  number
k rollout undo deployments/kubernetes-bootcamp --to-revision=1 

#To rollback to last or recent  change
k rollout undo deployments/kubernetes-bootcamp


#Delete the deployment
k delete deploy kubernetes-bootcamp



