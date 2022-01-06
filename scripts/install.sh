#!/usr/bin/env zsh

are_you_sure()
{
  read -q "REPLY?$1(y/n)? "
  printf "\n"

  if [ "$REPLY" = "n" ]; then
    exit
  fi
}

are_you_sure "Are you sure"

set -x
set -e

# Ignore error
kubectl create ns minio-tenant-1 && echo -n

kubens minio-tenant-1

# Ignore error
kubectl delete secret minio-tenant-1-tls && echo -n

# Add Minio TLS certificate
kubectl create secret generic minio-tenant-1-tls  --from-file=../cert/private.key --from-file=../cert/public.crt

kubectl minio tenant create minio-tenant-1 \
--servers          3                     \
--volumes          6                     \
--capacity         100Gi                 \
--namespace        minio-tenant-1        \
--storage-class minio-local-storage

kubect apply -f ../yaml/minio-ingress.yaml
