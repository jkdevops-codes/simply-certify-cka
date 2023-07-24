k create role pod-reader --verb=get,list --resource=pods --dry-run=client -oyaml > pod-reader-role.yml
vim pod-reader-role.yml
k apply -f pod-reader-role.yml


k create rolebinding pod-reader-rolebinding --role=pod-reader --user=user1 --dry-run=client -oyaml > pod-reader-rolebinding.yml 
vim pod-reader-rolebinding.yml
k apply -f pod-reader-rolebinding.yml


k auth can-i get secrets --as user1
k auth can-i get pods  --as user1
k auth can-i create pods  --as user1



k get pods --context=user1-context 

