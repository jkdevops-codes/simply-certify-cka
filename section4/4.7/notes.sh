A. k run  myhttp --image=nginx:latest --dry-run=client -oyaml > myhttp.yaml
   k apply -f myhttp.yaml

B. k expose pod myhttp --name=myservice --port=8080 --target-port=80 --type=NodePort 