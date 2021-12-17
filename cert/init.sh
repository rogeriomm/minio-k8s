kubectl create ns minio-tenant-1
kubens minio-tenant-1
kubectl create secret generic minio-tenant-1-tls  --from-file=private.key --from-file=public.crt
kubectl get secrets
kubectl get secret/minio-tenant-1-tls  -o yaml | yh
