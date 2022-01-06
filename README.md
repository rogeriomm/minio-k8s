
# Install
## Setup Krew
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

## Create Minio operator
```commandline
kubectl krew update
kubectl krew install minio
kubectl minio version
kubectl minio init --namespace minio-operator
```

```commandline
kubectl krew update minio
```

```commandline
kubectl get deployments -A --field-selector metadata.name=minio-operator
```

## Create instance namespace

```commandline
kubectl create ns minio-tenant-1
```

## Create Minio instance
   * Ensure the Minio persistent volumes exist and are available
```commandline
kubectl get pv | grep minio-local-storage
```

```commandline
kubectl minio tenant create minio-tenant-1 \
--servers          3                     \
--volumes          6                     \
--capacity         100Gi                 \
--namespace        minio-tenant-1        \
--storage-class minio-local-storage
```

```commandline
kubens minio-tenant-1
kubectl get pvc
```

```text
I1216 17:38:37.190045   21518 tenant-create.go:69] create tenant command started

Tenant 'minio-tenant-1' created in 'minio-tenant-1' Namespace

  Username: admin
  Password: e38c92d3-3905-4817-a7ba-e9081a2b4fde
  Note: Copy the credentials to a secure location. MinIO will not display these again.

+-------------+------------------------+----------------+--------------+--------------+
| APPLICATION | SERVICE NAME           | NAMESPACE      | SERVICE TYPE | SERVICE PORT |
+-------------+------------------------+----------------+--------------+--------------+
| MinIO       | minio                  | minio-tenant-1 | ClusterIP    | 443          |
| Console     | minio-tenant-1-console | minio-tenant-1 | ClusterIP    | 9443         |
+-------------+------------------------+----------------+--------------+--------------+
```
## Create Minio console ingress
```commandline
cd yaml
kubectl apply -f minio-ingress.yaml
```

# How to delete Minio instance
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


# Minio console
   * https://minio-tenant-1-console.minio-tenant-1.svc.cluster.local:9443/: Minio console

```commandline
kubeclt minio proxy
```
# Minio API
   * https://minio.minio-tenant-1.svc.cluster.local

# Minio client
   * https://docs.min.io/docs/minio-client-complete-guide: MinIO Client Complete Guide
```commandline
brew install minio/stable/mc
```

# AWS S3 
   * https://docs.min.io/docs/aws-cli-with-minio.html: AWS CLI with MinIO Server 
   * https://stackoverflow.com/questions/32946050/ssl-certificate-verify-failed-in-aws-cli: SSL CERTIFICATE_VERIFY_FAILED in aws cli
   * https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html: Environment variables to configure the AWS CLI
## Configure
   * https://docs.min.io/docs/aws-cli-with-minio.html: AWS CLI with MinIO Server
```commandline
aws configure
aws configure set default.s3.signature_version s3v4
```
## List files
```commandline
aws --no-verify-ssl  --endpoint-url https://minio.minio-tenant-1.svc.cluster.local s3 ls
aws --no-verify-ssl  --endpoint-url https://minio.minio-tenant-1.svc.cluster.local s3 ls s3://kaggle
```

## Copy file
```commandline
aws --no-verify-ssl  --endpoint-url https://minio.minio-tenant-1.svc.cluster.local s3 cp ./cluster.local s3://landing
```

## Delete file
```commandline
aws --no-verify-ssl  --endpoint-url https://minio.minio-tenant-1.svc.cluster.local s3  rm s3://landing/cluster.local
```

# Tools
   * https://s3tools.org/s3cmd: Amazon S3 Tools: Command Line S3 Client Software and S3 Backup
   * 
# See also
   * [Certificates](docs/Certificate.md)
   * [Jetbrains configuration](docs/Jetbrains.md)

# Reference
   * https://docs.min.io/minio/k8s/reference/minio-kubectl-plugin.html: MinIO Kubernetes Plugin
   * https://docs.min.io/minio/k8s/deployment/deploy-minio-operator.html#deploy-operator-kubernetes
      * https://github.com/minio/operator: MinIO Operator
   * https://blog.travismclarke.com/post/osx-cli-group-management/: OSX User/Group Management – Part 2: Groups
   * https://docs.min.io/minio/k8s/tenant-management/deploy-minio-tenant-using-commandline.html#deploy-minio-tenant-commandline
      * "MinIO strongly recommends using locally attached drives on each node intended to support the MinIO Tenant. MinIO’s strict read-after-write and list-after-write consistency model requires local disk filesystems (xfs, ext4, etc.). MinIO also shows best performance with locally-attached drives."
