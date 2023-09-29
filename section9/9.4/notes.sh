#Pods Affinity / AntiAffinity



k run my-web --image=nginx:alpine3.17 --labels="app=my-web,service-type=webserver" -oyaml --dry-run=client > my-web.yml
k apply -f my-web.yml

k run web-cache --image=redis:alpine3.18 --labels="app=web-cache,service-type=cache" -oyaml --dry-run=client > web-cache.yml


vim web-cache.yml
#Add the following under spec:
affinity:
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: service-type
            operator: In
            values:
            - webserver
        topologyKey: kubernetes.io/hostname



#pod AntiAffinity 
k delete -f web-cache.yml
vim web-cache.yml
#Add the following under spec:
affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: service-type
            operator: In
            values:
            - webserver
        topologyKey: kubernetes.io/hostname