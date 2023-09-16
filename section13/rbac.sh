
#You are tasked with setting up access controls within a Kubernetes cluster to manage permissions for a specific use case

#1. Create a namespace named library-staff-ns.
#2. Create a service account named library-staff-sa in the library-staff-ns namespace
#3. Create a Role named library-staff-role in the library-staff-ns namespace with permissions for get, watch, list, create, patch, update, and delete on the resources pods, configmaps, and secrets.
#4. Bind the library-staff-role Role to the library-staff-sa service account, ensuring that the assigned permissions are granted to the service account.

#After completing these steps, the pods running within the library-staff-ns namespace should be able to communicate with the assigned permissions.


#1
alias k=kubectl
k create ns library-staff-ns

#2. 
k create sa library-staff-sa -n library-staff-ns


#3. create library-staff-role
k create role library-staff-role --verb=get,list,watch,update,patch,create,delete --resource=pods,configmaps,secrets -n library-staff-ns

#4. create library-staff-role-binding
k create rolebinding library-staff-rolebinding --role=library-staff-role --serviceaccount=library-staff-ns:library-staff-sa -n library-staff-ns

#5. 
k auth can-i create  pod --as=system:serviceaccount:library-staff-ns:library-staff-sa -n library-staff-ns




