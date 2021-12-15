

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
--storage-class local-storage
```

```text
I1215 13:11:21.321534   23679 tenant-create.go:69] create tenant command started

Tenant 'minio-tenant-1' created in 'minio-tenant-1' Namespace

  Username: admin
  Password: cefbef89-0505-4a20-99fa-27b29b2dac47
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
```

# Minio console
   * https://minio-tenant-1-console.minio-tenant-1.svc.cluster.local:9443/: Minio console

```commandline
kubeclt minio proxy
```

# Reference
   * https://docs.min.io/minio/k8s/reference/minio-kubectl-plugin.html: MinIO Kubernetes Plugin
   * https://docs.min.io/minio/k8s/deployment/deploy-minio-operator.html#deploy-operator-kubernetes
      * https://github.com/minio/operator: MinIO Operator
   * https://blog.travismclarke.com/post/osx-cli-group-management/: OSX User/Group Management – Part 2: Groups
