cat <<EOF >> mongo-svc.yml
apiVersion: v1
kind: Service
metadata:
  name: mongo
spec:
  type: ExternalName
  externalName: ds54673424.mlab.com
EOF



k apply -f  mongo-svc.yml