
# Install
## Setup Krew
```shell
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)
```

```shell
kubectl krew update
kubectl krew upgrade
kubectl krew list
```


## Create Minio operator
```shell
kubectl krew update minio
kubectl krew install minio
kubectl minio version
kubectl minio init --namespace minio-operator
```

```shell
kubectl get deployments -A --field-selector metadata.name=minio-operator
```

## Create instance namespace

```shell
kubectl create ns minio-tenant-1
```

## Create Minio instance
   * Ensure the Minio persistent volumes exist and are available
```shell
kubectl get pv | grep minio-local-storage
```

```shell
kubectl minio --namespace minio-tenant-1 tenant delete minio-tenant-1
```

```shell
kubectl minio tenant create minio-tenant-1 \
--servers          3                     \
--volumes          6                     \
--capacity         100Gi                 \
--namespace        minio-tenant-1        \
--storage-class minio-local-storage
```

```shell
kubens minio-tenant-1
kubectl get pvc
```

```text
Tenant 'minio-tenant-1' created in 'minio-tenant-1' Namespace

  Username: admin
  Password: fd24e98f-94dc-4c61-b255-e320a5ee516d
  Note: Copy the credentials to a secure location. MinIO will not display these again.

+-------------+------------------------+----------------+--------------+--------------+
| APPLICATION | SERVICE NAME           | NAMESPACE      | SERVICE TYPE | SERVICE PORT |
+-------------+------------------------+----------------+--------------+--------------+
| MinIO       | minio                  | minio-tenant-1 | ClusterIP    | 443          |
| Console     | minio-tenant-1-console | minio-tenant-1 | ClusterIP    | 9443         |
+-------------+------------------------+----------------+--------------+--------------+
```
## Create Minio console ingress
```shell
kubectl apply -f yaml/minio-ingress.yaml
```

## Set certificate


# How to delete Minio instance
```shell
kubectl minio tenant delete minio-tenant-1 --namespace minio-tenant-1
kubectl delete ns minio-tenant-1
kubectl delete pv/local-storage-pv000{1,2,3,4,5,6}
scripts/clean-pv.sh
```


# Minio console
   * https://minio-tenant-1-console.minio-tenant-1.svc.cluster.local:9443/: Minio console

```shell
kubeclt minio proxy
```
# Minio API
   * https://minio.minio-tenant-1.svc.cluster.local

# Minio client
   * https://docs.min.io/docs/minio-client-complete-guide: MinIO Client Complete Guide
```shell
brew install minio/stable/mc
```

# AWS S3 
   * https://docs.min.io/docs/aws-cli-with-minio.html: AWS CLI with MinIO Server 
   * https://stackoverflow.com/questions/32946050/ssl-certificate-verify-failed-in-aws-cli: SSL CERTIFICATE_VERIFY_FAILED in aws cli
   * https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html: Environment variables to configure the AWS CLI
## Configure
   * https://docs.min.io/docs/aws-cli-with-minio.html: AWS CLI with MinIO Server
```shell
aws configure
aws configure set default.s3.signature_version s3v4
```
## List files
```shell
aws --endpoint-url https://minio.minio-tenant-1.svc.cluster.local s3 ls
aws --endpoint-url https://minio.minio-tenant-1.svc.cluster.local s3 ls s3://kaggle
```

## Copy file
```shell
aws --endpoint-url https://minio.minio-tenant-1.svc.cluster.local s3 cp ./cluster.local s3://landing
```

## Delete file
```shell
aws --endpoint-url https://minio.minio-tenant-1.svc.cluster.local s3  rm s3://landing/cluster.local
```

# Tools
   * https://s3tools.org/s3cmd: Amazon S3 Tools: Command Line S3 Client Software and S3 Backup

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
