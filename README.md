

```commandline
(                                                                                                                                              ─╯
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/download/v0.4.2/krew-darwin_amd64.tar.gz" &&
  tar zxvf krew-darwin_amd64.tar.gz &&
  KREW=./krew-"${OS}_${ARCH}" &&
  "$KREW" install krew
)
```

```commandline
kubectl krew update
kubectl krew install minio
kubectl minio version
kubectl minio init --namespace minio-operator
```

```commandline
kubectl get deployments -A --field-selector metadata.name=minio-operator
```

```commandline
kubectl create ns minio-tenant-1
```
```commandline
kubectl minio tenant create minio-tenant-1 \
--servers          3                     \
--volumes          6                     \
--capacity         100Gi                 \
--namespace        minio-tenant-1        \
--storage-class minio-local-storage
```

```text
I1216 17:38:37.190045   21518 tenant-create.go:69] create tenant command started

Tenant 'minio-tenant-1' created in 'minio-tenant-1' Namespace

  Username: admin
  Password: f876a12a-d5af-475d-aeeb-a780e788805f
  Note: Copy the credentials to a secure location. MinIO will not display these again.

+-------------+------------------------+----------------+--------------+--------------+
| APPLICATION | SERVICE NAME           | NAMESPACE      | SERVICE TYPE | SERVICE PORT |
+-------------+------------------------+----------------+--------------+--------------+
| MinIO       | minio                  | minio-tenant-1 | ClusterIP    | 443          |
| Console     | minio-tenant-1-console | minio-tenant-1 | ClusterIP    | 9443         |
+-------------+------------------------+----------------+--------------+--------------+
```

```commandline
kubectl minio tenant delete minio-tenant-1 --namespace minio-tenant-1
kubectl delete ns minio-tenant-1
kubectl delete pv/local-storage-pv000{1,2,3,4,5,6}
minikube --node=cluster2     ssh "sudo rm -rf /data/local-storage/pv000{1,2,3,4,5,6}/.minio.sys"
minikube --node=cluster2-m02 ssh "sudo rm -rf /data/local-storage/pv000{1,2,3,4,5,6}/.minio.sys"
minikube --node=cluster2-m03 ssh "sudo rm -rf /data/local-storage/pv000{1,2,3,4,5,6}/.minio.sys"
minikube --node=cluster2     ssh "sudo rm -rf /data/local-storage/pv000{1,2,3,4,5,6}/*"
minikube --node=cluster2-m02 ssh "sudo rm -rf /data/local-storage/pv000{1,2,3,4,5,6}/*"
minikube --node=cluster2-m03 ssh "sudo rm -rf /data/local-storage/pv000{1,2,3,4,5,6}/*"
```
# Minio certificate
   * https://github.com/minio/minio/tree/master/docs/tls/kubernetes: How to secure access to MinIO on Kubernetes with TLS
   * "*.minio-tenant-1-hl.minio-tenant-1.svc.cluster.local"

```commandline
openssl genrsa -out private.key 2048
openssl req -new -x509 -nodes -days 730 -key private.key -out public.crt -config openssl.conf
```

# Minio console
   * https://minio-tenant-1-console.minio-tenant-1.svc.cluster.local:9443/: Minio console

```commandline
kubeclt minio proxy
```
# Minio API
   * https://minio.minio-tenant-1.svc.cluster.local

# Reference
   * https://docs.min.io/minio/k8s/reference/minio-kubectl-plugin.html: MinIO Kubernetes Plugin
   * https://docs.min.io/minio/k8s/deployment/deploy-minio-operator.html#deploy-operator-kubernetes
      * https://github.com/minio/operator: MinIO Operator
   * https://blog.travismclarke.com/post/osx-cli-group-management/: OSX User/Group Management – Part 2: Groups
   * https://docs.min.io/minio/k8s/tenant-management/deploy-minio-tenant-using-commandline.html#deploy-minio-tenant-commandline
      * "MinIO strongly recommends using locally attached drives on each node intended to support the MinIO Tenant. MinIO’s strict read-after-write and list-after-write consistency model requires local disk filesystems (xfs, ext4, etc.). MinIO also shows best performance with locally-attached drives."
