#Question:-
1. Create a Kubernetes service account called sa-reader in the namespace ns-reader.

2. Create a role r-reader and a rolebinding rb-reader in the namespace ns-reader and give the permissions list, get, and watch to resources secrets, configmaps, and pods for the service account sa-reader.

3. Test if a the Service Account sa-reader  having applied permission


#Answer:-


#1. 
k create ns  ns-reader
k create sa sa-reader -n ns-reader

#2
k create role r-reader -n ns-reader --verb=list,get,watch --resource=pods,secrets,configmaps
k create rolebinding rb-reader  -n ns-reader --serviceaccount=ns-reader:sa-reader  --role=r-reader

#3
k auth can-i list pods --as=system:serviceaccount:ns-reader:sa-reader  -n ns-reader




