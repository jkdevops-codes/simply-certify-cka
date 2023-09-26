k run myapp --image=nginx --labels="app=myapp" --port=80 
k expose pod/myapp --port=8080 --target-port=80


k run netchecker --image=nginx --labels="app=netchecker" --port=80 


k exec -it netchecker -- apt update
k exec -it netchecker -- apt install dnsutils


#Check the curl call from netchecker to myapp
k exec -it netchecker -- curl <pod ip>
k exec -it netchecker -- curl myapp:8080


#Check the nslookup from netchecker to myapp
k exec -it netchecker -- nslookup <pod ip>
k exec -it netchecker -- curl myapp:8080





