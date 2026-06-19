helm install hello-world . \
   --namespace hello-world \
    --create-namespace \
    --set message="Hola mundo"